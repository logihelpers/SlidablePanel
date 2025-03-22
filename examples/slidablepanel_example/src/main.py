import flet as ft

from slidablepanel import SlidablePanel


def main(page: ft.Page):
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    page.add(
        pane := SlidablePanel(
            content_width=200,
            content=ft.Container(
                content=ft.Text("Hallelujah")
            ),
        )
    )


ft.app(main)
