# Alias

Este programa ayuda a crear, editar, ver, eliminar o copiar alias de tu archivo que contenga los alias (.bashrc por ejemplo).

Ejemplo para listar/ver los alias.
```shell
malias -l
```

## Instalación

Es una instalación muy básica, solo te añade un alias para ejecutar el script

```shell
git clone https://github.com/victormln/alias.git
cd alias
./install.sh
```

## Configuración

Se pueden configurar varios parámetros. Por ejemplo que no busque actualizaciones automáticas, cambiar el idioma o poner el archivo donde se encuentran tus alias. Si se abre el archivo **user.conf** se podrán acceder a todas las configuraciones.

## Uso

Este script tiene varios usos. Un ejemplo para añadir un alias
```shell
alias -a test1
```

Todos los argumentos disponibles:

|Argumento           |Abreviado|Significado                                   |Uso|
| ------------- | ---- | ---------------------------------------- |----------|
|`--help`       |`-h`     | Muestra los comandos disponibles         |`--help`  |
|`list` or `view` or `show` |`-l`  | Muestra los alias que tienes             |`-l`    |
|`add`     |`-a`  | Añade un alias   |`-a test1`      |
|`edit`     |`-e`  | Edita un alias   |`-e test1`      |
|`delete`     |`-d`  | Elimina un alias   |`-d test1`      |
|`copy`     |`-cp`  | Copia un alias existente por otro nuevo   |`-cp alias_origen alias_destino`      |
|`--conf`     |  | Abre/edita el archivo de configuración del script  |`--conf`      |.
|`--empty`     |  | Elimina alias y líneas vacías   |`--empty`      |
|`--restore`     |  | Restaura una copia de seguridad que se haya hecho antes de una acción.  |`--restore`      |
|`--update`     |  | Fuerza el buscar una actualización.  |`--update`      |
|     |`-v`  | Muestra la versión del script.  |`-v`      |
