import flet as ft

from slidablepanel import SlidablePanel


def main(page: ft.Page):
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    page.add(
        pane := SlidablePanel(
            sidebar_width=200,
            sidebar_bgcolor="red",
            main_pane_bgcolor="blue",
            sidebar=ft.Container(
                content=ft.Text("Hallelujah")
            ),
            main_pane=ft.Container(
                expand=True,
                content=ft.TextButton(
                    "HIDE/REVEAL PANEL",
                    on_click=lambda e: pane.toggle_panel()
                )
            )
        )
    )


ft.app(main)
