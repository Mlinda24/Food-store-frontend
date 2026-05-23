#!/bin/bash

# Replace all AppTheme.cardGlowGradient with the actual gradient
find lib -name "*.dart" -type f -exec sed -i 's/AppTheme\.cardGlowGradient/const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight)/g' {} \;

# Fix the specific ternary operator issue
find lib -name "*.dart" -type f -exec sed -i 's/hasItems ? AppTheme\.primaryButtonGradient : const LinearGradient(colors: \[Color(0xFFFFFFFF), Color(0xFFF5F5F5)\], begin: Alignment.topLeft, end: Alignment.bottomRight)/hasItems ? AppTheme.primaryButtonGradient : const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight)/g' {} \;

echo "Gradient fixes applied!"
