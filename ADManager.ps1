if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "El módulo no está instalado. Instalando..." -ForegroundColor Yellow
    try {
        Install-Module -Name ActiveDirectory -Force -Scope CurrentUser
        Write-Host "Módulo instalado correctamente." -ForegroundColor Green
    } catch {
        Write-Host "Error al intentar instalar el módulo: $_" -ForegroundColor Red
        exit
    }
} else {
    Write-Host "El módulo ya está instalado." -ForegroundColor Green
    Start-Sleep -Seconds 1
}

Import-Module ActiveDirectory

function PwdLastSet {
    $usuarioEncontrado = $false  

    do {
        $usuario = Read-Host -Prompt "Introduce el nombre de usuario (sAMAccountName)" 

        if ([string]::IsNullOrWhiteSpace($usuario)) {
            Write-Host -ForegroundColor Red "No se ha proporcionado un nombre de usuario."
            return
        }

        try {
            $user = Get-ADUser -Identity $usuario -Properties pwdLastSet -ErrorAction Stop
            $usuarioEncontrado = $true  
        } catch {
            Write-Host -ForegroundColor Red "✘ El usuario '$usuario' no se encontró o no existe en Active Directory."
            $intentarDeNuevo = Read-Host "¿Desea intentar con otro usuario? (Sí/No)"
            if ($intentarDeNuevo.ToLower() -ne "si") {
                return
            }
        }
    } while (-not $usuarioEncontrado)

    try {
        Set-ADUser -Identity $usuario -Replace @{pwdLastSet=0}
        Write-Host -ForegroundColor Green "✔️ Atributo 'pwdLastSet' cambiado a 0 para el usuario '$usuario'."
        Start-Sleep -Seconds 1

        Set-ADUser -Identity $usuario -Replace @{pwdLastSet=-1}
        Write-Host -ForegroundColor Green "✔️ Atributo 'pwdLastSet' cambiado a -1 para el usuario '$usuario'."

        $user = Get-ADUser -Identity $usuario -Properties pwdLastSet
        Write-Host -ForegroundColor Cyan "Nuevo valor de 'pwdLastSet' para el usuario '$usuario': $($user.pwdLastSet)"
    } catch {
        Write-Host -ForegroundColor Red "✘ Ocurrió un error al intentar cambiar el atributo 'pwdLastSet' para el usuario '$usuario'."
    }
}

function Insertar-Valores {
    $usuarioEncontrado = $false  

    do {
        $usuario = Read-Host "Ingrese el nombre de usuario de dominio"

        try {
            $validacion = Get-ADUser -Identity $usuario -Properties cn, employeeID, employeeNumber
            if ($validacion -ne $null) {
                Write-Host -ForegroundColor Yellow "Configurando al usuario: $($validacion.cn)"
                $usuarioEncontrado = $true  
            }
        } catch {
            Write-Host -ForegroundColor Red "✘ El usuario $usuario no se encontró en Active Directory o ocurrió un error."
            $intentarDeNuevo = Read-Host "¿Desea intentar con otro usuario? (Sí/No)"
            if ($intentarDeNuevo.ToLower() -ne "si") {
                return
            }
        }
    } while (-not $usuarioEncontrado)

    $cambioRealizado = $false
    $nuevosValores = @{}

    if ($validacion.employeeID) {
        Write-Host -ForegroundColor Yellow "El atributo employeeID ya tiene el valor: $($validacion.employeeID)"
        $overwriteEmployeeID = Read-Host "¿Desea sobrescribirlo? (Si/No)"
        if ($overwriteEmployeeID -eq "Si") {
            $nuevosValores.employeeID = Read-Host "Ingrese el nuevo valor para el atributo employeeID"
            $cambioRealizado = $true
        } else {
            Write-Host -ForegroundColor Yellow "No se sobrescribirá el atributo employeeID."
        }
    } else {
        $nuevosValores.employeeID = Read-Host "Ingrese el valor para el atributo employeeID"
        $cambioRealizado = $true
    }

    if ($validacion.employeeNumber) {
        Write-Host -ForegroundColor Yellow "El atributo employeeNumber ya tiene el valor: $($validacion.employeeNumber)"
        $overwriteEmployeeNumber = Read-Host "¿Desea sobrescribirlo? (Si/No)"
        if ($overwriteEmployeeNumber -eq "Si") {
            $nuevosValores.employeeNumber = Read-Host "Ingrese el nuevo valor para el atributo employeeNumber"
            $cambioRealizado = $true
        } else {
            Write-Host -ForegroundColor Yellow "No se sobrescribirá el atributo employeeNumber."
        }
    } else {
        $nuevosValores.employeeNumber = Read-Host "Ingrese el valor para el atributo employeeNumber"
        $cambioRealizado = $true
    }

    if ($cambioRealizado) {
        Set-ADUser -Identity $usuario -Replace $nuevosValores
        Write-Host -ForegroundColor Green "✔️ Los atributos han sido actualizados correctamente para el usuario $usuario"
    } else {
        Write-Host -ForegroundColor Yellow "No se realizaron cambios en los atributos del usuario $usuario."
    }
}

function Buscar-Usuario {
    do {
        $searchValue = Read-Host "Ingrese el nombre de usuario (sAMAccountName), employeeID o employeeNumber"

        try {
            $user = Get-ADUser -Filter {
                sAMAccountName -eq $searchValue -or
                employeeID -eq $searchValue -or
                employeeNumber -eq $searchValue
            } -Properties sAMAccountName, employeeID, employeeNumber, cn

            if ($user) {
                Write-Host "`nInformación del Usuario Encontrado:" -ForegroundColor Green
                Write-Host "   ➤ Nombre Completo: $($user.cn)" -ForegroundColor White
                Write-Host "   ➤ sAMAccountName: $($user.sAMAccountName)" -ForegroundColor Cyan
                Write-Host "   ➤ employeeID: $($user.employeeID)" -ForegroundColor Cyan
                Write-Host "   ➤ employeeNumber: $($user.employeeNumber)" -ForegroundColor Cyan
            } else {
                Write-Host "`nNo se encontró ningún usuario con el valor '$searchValue'." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Ocurrió un error al buscar el usuario: $_" -ForegroundColor Red
        }

        $continue = Read-Host "¿Deseas consultar otro usuario? (Sí/No)"
        if ($continue -match "^(sí|si)$") {
            continue
        } elseif ($continue -match "^(no)$") {
            break
        }
    } while ($true)
}

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "======================" -ForegroundColor Yellow
    Write-Host "      MENÚ PRINCIPAL" -ForegroundColor Green
    Write-Host "======================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   1. Cambiar pwdLastSet" -ForegroundColor Cyan
    Write-Host "   2. Insertar valores de atributos" -ForegroundColor Cyan
    Write-Host "   3. Buscar Usuario (sAMAccountName, employeeID o employeeNumber)" -ForegroundColor Cyan
    Write-Host "   0. Salir" -ForegroundColor Red
    Write-Host ""
}

do {
    Show-Menu
    $option = Read-Host "Elige una opción"
    
    switch ($option) {
        1 { PwdLastSet }
        2 { Insertar-Valores }
        3 { Buscar-Usuario }
        0 { Write-Host -ForegroundColor Green "Saliendo..."; break }
        default { Write-Host -ForegroundColor Red " Opción no válida. Intenta nuevamente." }
    }

    Start-Sleep -Seconds 1
} while ($option -ne 0)
