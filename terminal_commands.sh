# Nettoyer le cache Gradle
./gradlew --stop
rm -rf ~/.gradle/caches/

# Nettoyer le cache Flutter
flutter clean

# Supprimer les builds précédents
rm -rf build/
rm -rf android/app/build/

# Vider le cache pub
flutter pub cache clean

# Supprimer les fichiers temporaires
rm -rf /tmp/*
