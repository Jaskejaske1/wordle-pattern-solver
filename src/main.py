import flet as ft
import urllib.request
import threading
import json
import datetime

# --- LOGICA ---
def get_word_list():
    url = "https://raw.githubusercontent.com/charlesreid1/five-letter-words/master/sgb-words.txt"
    try:
        response = urllib.request.urlopen(url, timeout=5)
        data = response.read().decode('utf-8')
        return [w.upper() for w in data.splitlines() if len(w) == 5]
    except Exception as e:
        print(f"Fout: {e}")
        return []

def get_todays_solution():
    try:
        today = datetime.date.today().strftime("%Y-%m-%d")
        url = f"https://www.nytimes.com/svc/wordle/v2/{today}.json"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            return data.get("solution", "STRUT").upper()
    except:
        return "STRUT"

def calculate_real_pattern(candidate, target):
    target_chars = list(target)
    cand_chars = list(candidate)
    result = [0] * 5
    
    for i in range(5):
        if cand_chars[i] == target_chars[i]:
            result[i] = 2
            target_chars[i] = None
            cand_chars[i] = None
    for i in range(5):
        if cand_chars[i] is not None:
            if cand_chars[i] in target_chars:
                result[i] = 1
                target_chars.remove(cand_chars[i])
            else:
                result[i] = 0
    return result

# --- UI COMPONENTEN ---

class WordleRow(ft.Row):
    def __init__(self, app, index):
        super().__init__()
        self.app = app
        self.index = index
        self.states = [0] * 5
        self.matches = []
        self.current_match_index = 0
        self.tile_texts = [] 
        self.tile_containers = []
        self.TILE_SIZE = 45
        self.SPACING = 6 
        self.spacing = self.SPACING
        self.alignment = ft.MainAxisAlignment.CENTER
        self.vertical_alignment = ft.CrossAxisAlignment.CENTER
        self._build_controls()

    def _build_controls(self):
        for i in range(5):
            letter_text = ft.Text(value="", size=24, weight=ft.FontWeight.BOLD, color=ft.Colors.WHITE)
            self.tile_texts.append(letter_text)
            tile = ft.Container(
                width=self.TILE_SIZE, height=self.TILE_SIZE,
                bgcolor=ft.Colors.GREY_800,
                border=ft.Border.all(2, ft.Colors.GREY_700),
                alignment=ft.Alignment(0, 0),
                content=letter_text,
                on_click=lambda e, col=i: self.toggle_tile(col),
                animate=ft.Animation(150, ft.AnimationCurve.EASE_OUT)
            )
            self.tile_containers.append(tile)

        self.count_label = ft.Text(value="", size=10, color=ft.Colors.GREY_500, width=40, text_align=ft.TextAlign.CENTER)
        self.next_btn = ft.IconButton(
            icon=ft.Icons.REFRESH, icon_size=20, icon_color=ft.Colors.BLUE_400,
            tooltip="Volgend woord", on_click=self.next_suggestion,
            style=ft.ButtonStyle(padding=0), width=30, height=30
        )
        controls_container = ft.Container(
            height=self.TILE_SIZE, alignment=ft.Alignment(0, 0),
            content=ft.Column([self.next_btn, self.count_label], spacing=0, alignment=ft.MainAxisAlignment.CENTER)
        )
        self.controls = [*self.tile_containers, ft.Container(width=5), controls_container]

    def toggle_tile(self, col_idx):
        current = self.states[col_idx]
        is_strict = self.app.strict_mode_switch.value
        self.states[col_idx] = (current + 1) % 3 if is_strict else (0 if current != 0 else 1)
        self.update_tile_visuals(col_idx)
        threading.Thread(target=self.app.solve_row, args=(self,), daemon=True).start()

    def update_tile_visuals(self, col_idx):
        state = self.states[col_idx]
        tile = self.tile_containers[col_idx]
        is_strict = self.app.strict_mode_switch.value
        if state == 0:
            tile.bgcolor, tile.border = ft.Colors.GREY_800, ft.Border.all(2, ft.Colors.GREY_700)
        elif not is_strict:
            tile.bgcolor, tile.border = ft.Colors.BLUE, None
        else:
            tile.bgcolor = ft.Colors.YELLOW_700 if state == 1 else ft.Colors.GREEN_700
            tile.border = None
        tile.update()

    def update_content(self):
        count = len(self.matches)
        if count > 0:
            word = self.matches[self.current_match_index]
            for i in range(5): self.tile_texts[i].value = word[i]
            self.count_label.value = f"{self.current_match_index + 1}/{count}"
            self.count_label.color = ft.Colors.GREY_500
            self.next_btn.icon_color, self.next_btn.disabled = ft.Colors.BLUE_400, False
        else:
            for i in range(5): self.tile_texts[i].value = "?"
            self.count_label.value, self.count_label.color = "0", ft.Colors.RED_400
            self.next_btn.icon_color, self.next_btn.disabled = ft.Colors.GREY_800, True
        
        for txt in self.tile_texts: txt.update()
        self.count_label.update()
        self.next_btn.update()

    def next_suggestion(self, e):
        if not self.matches: return
        self.current_match_index = (self.current_match_index + 1) % len(self.matches)
        self.update_content()
        
    def reset(self):
        self.states = [0] * 5
        self.current_match_index = 0
        for i in range(5): self.update_tile_visuals(i)
        threading.Thread(target=self.app.solve_row, args=(self,), daemon=True).start()

# --- HOOFD APPLICATIE ---

class WordleApp:
    def __init__(self, page: ft.Page):
        self.page = page
        self.page.title = "Wordle Pattern Solver"
        self.page.theme_mode = ft.ThemeMode.DARK
        self.page.padding = 0
        
        # Start venstergrootte
        self.page.window.width = 900
        self.page.window.height = 700
        self.page.window.resizable = True 
        
        self.word_list = []
        self.rows = []

        self.create_controls()

        self.page.on_resized = self.handle_resize # type: ignore
        self.handle_resize(None)
        
        self.load_data_background()

    def create_controls(self):
        # 1. Input Sectie
        self.target_input = ft.TextField(
            value="LADEN...", label="DOELWOORD",
            text_style=ft.TextStyle(size=24, weight=ft.FontWeight.BOLD, letter_spacing=3),
            text_align=ft.TextAlign.CENTER, width=220, height=70,
            border_radius=12, border_width=2, max_length=5,
            capitalization=ft.TextCapitalization.CHARACTERS, content_padding=15,
            on_change=self.handle_input_change, hint_text="_____"
        )
        self.feedback_text = ft.Text(value="", size=12, weight=ft.FontWeight.BOLD)
        self.strict_mode_switch = ft.Switch(label="Strict", value=False, active_color=ft.Colors.GREEN, on_change=self.on_mode_change)
        self.reset_btn = ft.IconButton(icon=ft.Icons.DELETE_OUTLINE, icon_color=ft.Colors.RED_400, tooltip="Reset Grid", on_click=self.reset_grid)
        self.status_text = ft.Text("Starten...", size=12, color=ft.Colors.GREY_600)

        # 2. Header / Sidebar (Inhoud)
        self.control_panel = ft.Container(
            content=ft.Column(
                controls=[
                    self.target_input,
                    self.feedback_text,
                    ft.Row([self.strict_mode_switch, self.reset_btn], alignment=ft.MainAxisAlignment.CENTER),
                    ft.Container(height=10),
                    self.status_text
                ],
                horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                alignment=ft.MainAxisAlignment.CENTER,
                spacing=5
            ),
            bgcolor=ft.Colors.GREY_900, 
            alignment=ft.Alignment(0, 0)
        )

        # 3. Grid
        grid_col = ft.Column(spacing=6, scroll=ft.ScrollMode.AUTO)
        for i in range(6): 
            row = WordleRow(self, i)
            self.rows.append(row)
            grid_col.controls.append(row)
        
        self.grid_container = ft.Container(
            content=grid_col,
            padding=20,
            # AANPASSING: (0, 0) is midden-midden. Voorheen was dit (0, -1) [top-center]
            alignment=ft.Alignment(0, 0), 
            expand=True
        )

    def handle_resize(self, e):
        """Bepaalt layout en styling op basis van schermbreedte."""
        self.page.clean()
        
        current_width = self.page.width or self.page.window.width or 0
        
        if current_width > 700:
            # --- DESKTOP LAYOUT ---
            # Standaard padding rondom
            self.control_panel.padding = 20
            
            layout = ft.Row(
                controls=[
                    ft.Container(content=self.control_panel, width=300, alignment=ft.Alignment(0, 0)),
                    ft.VerticalDivider(width=1, color=ft.Colors.GREY_800),
                    self.grid_container
                ],
                expand=True,
                spacing=0
            )
        else:
            # --- MOBILE LAYOUT ---
            # AANPASSING: Extra padding aan de bovenkant (top=30) duwt doelwoord naar beneden
            self.control_panel.padding = ft.Padding(left=10, top=30, right=10, bottom=10)
            
            layout = ft.Column(
                controls=[
                    self.control_panel,
                    ft.Divider(height=1, color=ft.Colors.GREY_800),
                    self.grid_container
                ],
                expand=True,
                spacing=0
            )

        self.page.add(ft.SafeArea(layout, expand=True))
        self.page.update()

    def load_data_background(self):
        def task():
            try:
                self.status_text.value = "Downloaden..."
                self.status_text.update()
                self.word_list = get_word_list()
                solution = get_todays_solution()
                self.target_input.value = solution
                self.status_text.value = f"{len(self.word_list)} woorden."
            except Exception as e:
                self.target_input.value = "STRUT" 
                self.status_text.value = f"Error: {e}"
            finally:
                self.target_input.update()
                self.status_text.update()
                self.handle_input_change(None)
        threading.Thread(target=task, daemon=True).start()

    def handle_input_change(self, e):
        val = self.target_input.value.strip().upper()
        if len(val) == 5:
            if self.word_list and val in self.word_list:
                self.target_input.border_color = ft.Colors.GREEN
                self.feedback_text.value = "GELDIG"
                self.feedback_text.color = ft.Colors.GREEN
            elif self.word_list:
                self.target_input.border_color = ft.Colors.RED
                self.feedback_text.value = "ONBEKEND"
                self.feedback_text.color = ft.Colors.RED
        else:
            self.target_input.border_color = ft.Colors.BLUE
            self.feedback_text.value = ""
        self.target_input.update()
        self.feedback_text.update()
        self.refresh_all(e)

    def on_mode_change(self, e):
        for row in self.rows:
            for i in range(5): row.update_tile_visuals(i)
            threading.Thread(target=self.solve_row, args=(row,), daemon=True).start()

    def refresh_all(self, e):
        def refresh_task():
            for row in self.rows: self.solve_row(row)
        threading.Thread(target=refresh_task, daemon=True).start()
            
    def reset_grid(self, e):
        for row in self.rows: row.reset()

    def solve_row(self, row_obj):
        if not self.word_list: return
        target = self.target_input.value.strip().upper()
        if len(target) != 5:
            for i in range(5):
                row_obj.tile_texts[i].value = ""
                row_obj.tile_texts[i].update()
            return

        user_pattern = row_obj.states
        is_strict = self.strict_mode_switch.value
        matches = []
        for candidate in self.word_list:
            real_pattern = calculate_real_pattern(candidate, target)
            match = False
            if is_strict:
                if real_pattern == user_pattern: match = True
            else:
                match = True
                for k in range(5):
                    if (user_pattern[k] > 0) != (real_pattern[k] > 0):
                        match = False; break
            if match: matches.append(candidate)

        row_obj.matches = matches
        row_obj.current_match_index = 0
        row_obj.update_content()

def main(page: ft.Page):
    app = WordleApp(page)

ft.run(main)