# ADManager

ADManager es un conjunto de herramientas en PowerShell diseñadas para interactuar con Active Directory, permitiendo gestionar usuarios, modificar atributos y realizar búsquedas rápidas. 
## Funcionalidades

El script proporciona las siguientes funcionalidades:

1. **Instalación del módulo ActiveDirectory**: Si el módulo no está instalado en el sistema, se instalará automáticamente.
2. **Modificar el atributo `pwdLastSet`**: Permite restablecer el atributo `pwdLastSet` de un usuario, lo que puede ser útil para forzar el cambio de contraseña y reiniciar el tiempo de vida de la contraseña antes de que expire.
3. **Actualizar atributos de usuario**: Permite insertar o sobrescribir atributos como `employeeID` y `employeeNumber` para un usuario.
4. **Búsqueda de usuarios**: Busca usuarios en Active Directory utilizando su `sAMAccountName`, `employeeID` o `employeeNumber`.

## Requisitos

- PowerShell 5.1 o superior
- Módulo de PowerShell **ActiveDirectory** instalado

### Instalación del Módulo ActiveDirectory

Si el módulo **ActiveDirectory** no está instalado en el sistema, el script se encargará de instalarlo automáticamente.

## Uso

Para usar el script, simplemente ejecútalo en PowerShell. El menú interactivo te permitirá elegir qué acción realizar:

1. Cambiar el atributo `pwdLastSet` de un usuario.
2. Insertar valores de atributos para un usuario.
3. Buscar información de un usuario por `sAMAccountName`, `employeeID` o `employeeNumber`.

### Ejemplo de ejecución:

```bash
PS C:\> .\ADManager.ps1
```

## Licencia
Este proyecto es de código abierto bajo la licencia **MIT**. Puedes usarlo, modificarlo y compartirlo libremente.

##  Contribuciones
Si quieres mejorar el código o agregar nuevas funciones, ¡las contribuciones son bienvenidas! Puedes hacer un **fork**, modificarlo y abrir un **pull request**.
