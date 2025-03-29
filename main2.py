import os
import json
import random

# Archivo donde se guardará la lista
archivo = "lista_evento.txt"

# Cargar o inicializar la lista
if os.path.exists(archivo):
    with open(archivo, "r") as file:
        try:
            lista_evento = json.load(file)  # Cargar la lista desde el archivo
        except json.JSONDecodeError:
            lista_evento = []  # Inicializar si el archivo está vacío o tiene errores
else:
    lista_evento = [
        {
            "id_evento": 1,
            "usr_id": [],
            "match_list": [],
        },
        {
            "id_evento": 2,
            "usr_id": [],
            "match_list": [],
        },
        {
            "id_evento": 3,
            "usr_id": [],
            "match_list": [],
        }
    ]

# Función para agregar un usuario a un evento
def agregar_user(usr_id, evento):
    for i in lista_evento:
        if i["id_evento"] == evento:
            # Verificar si el usuario ya está en la lista de usuarios del evento
            if usr_id in i["usr_id"]:
                print("El usuario ya existe en este evento.")
            else:
                i["usr_id"].append(usr_id)  # Agregar el usuario al evento
                print("Usuario agregado correctamente.")
            return  # Salir de la función una vez procesado el evento
    print("Evento no encontrado.")

# Ejemplo de uso


def recorrer(dic):
    for i in dic:
        print(i["id_evento"])
        print(i["usr_id"])
        print(i["match_list"])
        


agregar_user(123, 3)  # Agregamos el usuario con ID 123 al evento 2

agregar_user(124, 3)  # Agregamos el usuario con ID 123 al evento 2

agregar_user(125, 3)  # Agregamos el usuario con ID 123 al evento 2

agregar_user(126, 3) 

agregar_user(110, 3) 

for i in range(0,100):
    agregar_user(i, 2)

def recorrer_matchs(evento, usr):
    usr = str(usr)  # Convertir el usuario a string
    for i in lista_evento:
        if i["id_evento"] == evento:
            print(f"Matches para el evento {evento}:")
            for match in i["match_list"]:
                # Comprobar si el usuario está en el match (en cualquier posición)
                if usr in match:
                    print(match)  # Mostrar los matches que incluyen al usuario
            return
    print("Evento no encontrado.")


def buscar(evento, usr):
    usr = str(usr)  # Convertir el usuario a string
    for i in lista_evento:
        if i["id_evento"] == evento:
            print("""
                                  
                                  
                                  
                                  ----------------------–----------------------–----------------------–
                                  
                                  
                                  """)
            print(f"Usuarios sin match con {usr} en el evento {evento}:")
            usuarios_con_match = set()  # Conjunto para almacenar usuarios con match con `usr`
            
            # Identificar usuarios que ya tienen match con `usr`
            for match in i["match_list"]:
                if usr in match:  # Verificar si `usr` está en el match
                    match_usuarios = match.split(" - ")
                    for u in match_usuarios:
                        if u != usr:
                            usuarios_con_match.add(u)
            
            # Iterar sobre los usuarios sin match
            for usuario in i["usr_id"]:
                if str(usuario) not in usuarios_con_match and str(usuario) != usr:
                    while True:
                        print(f"Usuario: {usuario}")
                        print("¿Qué deseas hacer?")
                        print("1: Dar match")
                        print("2: No dar match")
                        print("3: Salir")
                        opcion = input("Elige una opción: ")
                        
                        if opcion == "1":  # Dar match
                            # Tirar el dado
                            dado = random.randint(1, 6)
                            print(f"Tirando el dado... salió {dado}")
                            if dado % 2 == 0:  # Si el dado da un número par
                                crear_match(evento, usr, usuario)
                                print("¡MATCH EXITOSO!")
                            else:
                                print("El match no fue positivo.")
                            break
                        
                        elif opcion == "2":  # No dar match
                            print("No se dio match.")
                            
                            break
                        
                        elif opcion == "3":  # Salir
                            print("Saliendo de la función buscar...")
                            return
                    
            return
    print("Evento no encontrado.")



def abandonar(evento, usr):
    for i in lista_evento:
        if i["id_evento"] == evento:
            if usr in i["usr_id"]:
                i["usr_id"].remove(usr)  # Eliminar al usuario del evento
                print(f"Usuario {usr} ha abandonado el evento {evento}.")
            else:
                print(f"El usuario {usr} no está registrado en el evento {evento}.")
            return
    print("Evento no encontrado.")



def app(usr):
    evento = int(input("""
                   Ingresar opcion:
                   
1. Evento 1.
2. Evento 2.
3. Evento 3.

                   """))
    
    opcion = int(input("""
                       
                       Ingresar opcion:
                       
1. Ver matchs.
2. Buscar minita.
3. Abandonar evento. (ortiva)
                       
                       """))
    
    if opcion == 1:
        recorrer_matchs(evento, usr)
        app(usr)
    elif opcion == 2:
        buscar(evento, usr)
        app(usr)
    elif opcion == 3:
        abandonar(evento, usr)
        app(usr)

        
    
        
    

def crear_match(evento, usr1, usr2):
    existe = False
    for i in lista_evento:
        if i["id_evento"] == evento:
            for j in i["match_list"]:
                if ((j == (str(usr1) + " - " +str(usr2))) or (j == (str(usr2) + " - " +str(usr1)))):
                    existe = True
            if existe == False:
                print("Match creado correctamente")
                i["match_list"].append(str(usr1) + " - " +str(usr2))
            else:
                print("Ya existe el match!")

crear_match(3, 125, 123)
crear_match(3, 125, 124)
crear_match(3, 123, 125)
crear_match(3, 125, 126)


recorrer(lista_evento)


print("""
      
      
      ------------------------------------------------------------
      
      """)


app(123)


# Guardar la lista al finalizar el programa
with open(archivo, "w") as file:
    json.dump(lista_evento, file, indent=4)  # Guardar en formato JSON legible


