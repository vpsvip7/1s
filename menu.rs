use std::io;

fn main() {
    let mut running = true;
    
    while running {
        println!("\n--- Menú Principal ---");
        println!("1. Opción 1 speed");
        println!("2. Opción 2 update");
        println!("3. Opción 3 menu ");
        println!("4. Salir");
        println!("Seleccione una opción: ");

        let mut input = String::new();
        
        // Leer entrada del usuario
        io::stdin()
            .read_line(&mut input)
            .expect("Error al leer la entrada");

        // Convertir a número
        match input.trim().parse::<u32>() {
            Ok(opcion) => {
                match opcion {
                    1 => println!("speddtest"),
                    2 => println!("apt update"),
                    3 => println!("menu"),
                    4 => {
                        println!("Saliendo del programa...");
                        running = false;
                    },
                    _ => println!("Opción no válida"),
                }
            }
            Err(_) => println!("Entrada no válida, debe ser un número"),
        }
    }
}