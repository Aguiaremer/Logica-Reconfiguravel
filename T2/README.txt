Foi desenvolvido um testbench (cont_75_tb) para validação do funcionamento.

Simulações realizadas no ModelSim:

RTL: funcionamento correto, contagem de 15 até 89 conforme esperado.
Gate-Level: funcionamento correto, porém com atrasos de propagação visíveis.

Comparação:
Foi realizada uma simulação longa (~10s). O tempo de simulação em Gate-Level foi significativamente maior que o RTL, devido à consideração dos atrasos dos componentes.