Si no sabes que es un alias, te recomiendo que los utilices. Puedes ver el enlace en la wikipedia para saber porque son útiles: <a href="https://es.wikipedia.org/wiki/Alias_(Unix)" target="_blank">¿Qué és un alias?</a>
___

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
malias -a test1
```

Todos los argumentos disponibles:

|Argumento           |Abreviado|Significado                                   |Uso|
| ------------- | ---- | ---------------------------------------- |----------|
|`--help`       |`-h`     | Muestra los comandos disponibles         |`malias --help`  |
|`list` or `view` or `show` |`-l`  | Muestra los alias que tienes             |`malias -l`    |
|`add`     |`-a`  | Añade un alias   |`malias -a test1`      |
|`edit`     |`-e`  | Edita uno o varios alias   |`malias -e test1`      |
|`delete`     |`-d`  | Elimina uno o varios alias   |`malias -d test1 test2`      |
|`copy`     |`-cp`  | Copia uno o varios alias a través de otro ya creado   |`malias -cp alias_origen alias_nuevo alias_nuevo2`      |
|`--conf`     |  | Abre/edita el archivo de configuración del script  |`malias --conf`      |.
|`--empty`     |  | Elimina alias y líneas vacías   |`malias --empty`      |
|`--import`     |  | Importa unos alias que se encuentren en un archivo especificado.  |`malias --import directory/fileName.txt`      |
|`--install`     |  | Instala unos alias ya preparados.  |`malias --install deliverea`      |
|`--restore`     |  | Restaura una copia de seguridad que se haya hecho antes de una acción.  |`malias --restore`      |
|`--update`     |  | Fuerza el buscar una actualización.  |`malias --update`      |
|     |`-v`  | Muestra la versión del script.  |`malias -v`      |
