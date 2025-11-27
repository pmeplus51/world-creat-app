# Configuration Sign in with Apple

## Étapes pour activer Sign in with Apple

### 1. Configurer les Entitlements dans Xcode

1. Dans Xcode, sélectionne le projet "World-Creat 2" dans le navigateur
2. Sélectionne la target "World-Creat 2"
3. Va dans l'onglet "Signing & Capabilities"
4. Clique sur "+ Capability"
5. Ajoute "Sign in with Apple"

### 2. Vérifier le fichier Entitlements

Le fichier `World_Creat_2.entitlements` devrait contenir :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
```

### 3. Configurer dans Apple Developer Portal

1. Va sur [developer.apple.com](https://developer.apple.com)
2. Sélectionne ton App ID
3. Active "Sign in with Apple"
4. Sauvegarde les changements

### 4. Tester

L'app devrait maintenant permettre la connexion avec Apple ID.

