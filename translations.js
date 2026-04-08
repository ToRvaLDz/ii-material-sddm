.pragma library

var _lang = ""

var _translations = {
    "it": {
        "enter_password": "Inserisci password",
        "incorrect_password": "Password errata",
        "session": "Sessione",
        "user": "Utente",
        "kb": "KB",
        "locked": "Bloccato"
    },
    "es": {
        "enter_password": "Introducir contraseña",
        "incorrect_password": "Contraseña incorrecta",
        "session": "Sesión",
        "user": "Usuario",
        "kb": "KB",
        "locked": "Bloqueado"
    },
    "fr": {
        "enter_password": "Entrer le mot de passe",
        "incorrect_password": "Mot de passe incorrect",
        "session": "Session",
        "user": "Utilisateur",
        "kb": "KB",
        "locked": "Verrouillé"
    }
}

var _defaults = {
    "enter_password": "Enter password",
    "incorrect_password": "Incorrect password",
    "session": "Session",
    "user": "User",
    "kb": "KB",
    "locked": "Locked"
}

function setLanguage(lang) {
    _lang = lang.substring(0, 2).toLowerCase()
}

function tr(key) {
    return (_translations[_lang] && _translations[_lang][key]) || _defaults[key] || key
}
