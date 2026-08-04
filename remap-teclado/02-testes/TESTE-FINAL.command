#!/bin/bash
# TESTE FINAL: aperte a tecla '?' 3x e o Backspace fisico 3x.
# Duplo clique neste arquivo -> abre Terminal e roda o teste.
cd "$(dirname "$0")"
clear
echo "===================================================================="
echo " TESTE FINAL - '?' vs Backspace"
echo "===================================================================="
echo "Quando aparecer PRONTO, aperte EM ORDEM, 3x cada:"
echo "  1) a tecla '?'  (a que fica na posicao do Ctrl direito)"
echo "  2) o Backspace fisico (a tecla grande acima do Enter)"
echo "  NAO digite mais nada enquanto o teste roda."
echo "===================================================================="
echo
python3 "$(dirname "$0")/kbtest2.py" 60
echo
echo "Pronto! Se o hidutil estiver funcionando, a '?' deve mostrar kc=44"
echo "(slash). Se mostrar kc=62 (ctrl), o hidutil NAO casou com o teclado."
echo
read -p "Pressione ENTER para fechar..."
