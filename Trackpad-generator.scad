// Константы
$circle = 0;         // Круг
$square = 1;         // Прямоугольник
$rounded_square = 2; // Прямоугольник со скруглениями
$x_max = 40;         // Максимальное количество столбцов для генерации сетки
$y_max = 40;         // Максимальное количество строк для генерации сетки

// Параметры
shape = 2;                  // Форма трекпада (смотреть в константы)
rows = 6;                   // Количество строк
columns = 6;                // Количество столбцов
touchpad_width = 26;        // Общая ширина платы (мм)
touchpad_height = 26;       // Общая высота платы (мм)
diamond_spacing = .2;       // Минимальный зазор между вершинами соседних ромбов (мм)
corner_radius = 5.0;        // Радиус скругления углов (если выбран прямоугольник со скруглениями)
enable_ground_frame = 1;    // Включение земляной рамки (1 = да, 0 = нет)
ground_frame_width = 1.0;   // Толщина земляной рамки (мм)
ground_frame_offset = 0.5;  // Зазор между рамкой и сеткой (мм)

// Основной код
tip2tip_spacing_x = (diamond_spacing * 1.414);
tip2tip_spacing_y = (diamond_spacing * 1.414);
pitch_x = (touchpad_width / columns);
pitch_y = (touchpad_height / rows);
diamond_x_size = pitch_x - tip2tip_spacing_x;
diamond_y_size = pitch_y - tip2tip_spacing_y;

module generate_diamonds() {
    for (ii = [0 : 1 : $y_max - 1])
        translate([0, (ii * pitch_y) + tip2tip_spacing_y / 2, 0]) {
            for (jj = [0 : 1 : $x_max - 1])
                translate([(jj * pitch_x) + tip2tip_spacing_x / 2, 0, 0])
                    polygon(
                        points = [
                            [0, diamond_y_size / 2],
                            [diamond_x_size / 2, diamond_y_size],
                            [diamond_x_size, diamond_y_size / 2],
                            [diamond_x_size / 2, 0]
                        ],
                        paths = [[0, 1, 2, 3]]
                    );
        }
}

module frame_shape_origin() {
    if (shape == $circle) {
        translate([touchpad_width / 2, touchpad_height / 2, 0])
            circle(d = touchpad_width);
    } else if (shape == $square) {
        square([touchpad_width, touchpad_height]);
    } else if (shape == $rounded_square) {
        rounded_square_origin(touchpad_width, touchpad_height, corner_radius);
    }
}

module rounded_square_origin(w, h, r) {
    r = min(r, min(w / 2, h / 2));
    translate([r, r, 0])
        offset(r = r)
            square([w - 2 * r, h - 2 * r]);
}

rotate([0, 0, 0]) {
    if (enable_ground_frame == 1 && ground_frame_width > 0) {
        if (shape == $rounded_square && ground_frame_width >= corner_radius) {
            echo("WARNING: ground_frame_width >= corner_radius. Это может вызвать артефакты геометрии!");
        }
        difference() {
            frame_shape_origin();
            offset(r = -ground_frame_width) frame_shape_origin();
        }
    }
    diamond_clip_radius = enable_ground_frame
                          ? (ground_frame_width + ground_frame_offset)
                          : 0;
    intersection() {
        translate([-pitch_x, -pitch_y, 0]) {
            union() {
                generate_diamonds();
                translate([pitch_x / 2, pitch_y / 2, 0])
                    generate_diamonds();
            }
        }
        if (diamond_clip_radius > 0) {
            offset(r = -diamond_clip_radius) frame_shape_origin();
        } else {
            frame_shape_origin();
        }
    }
}