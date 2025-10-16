[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/sEFmt2_p)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=21085106&assignment_repo_type=AssignmentRepo)
# Lab02 - Unidad Aritmético-Lógica.

# Integrantes

* [Julián Andrés Mancipe Muñoz](https://github.com/JuliTO65)
* [David Santiago Díaz Rivera](https://github.com/Davidx025)
* [Mariá José Morales Villacres](https://github.com/MariaJoseM0)

# Informe

Indice:

1. [Diseño implementado](#diseño-implementado)
2. [Simulaciones](#simulaciones)
3. [Implementación](#implementación)
4. [Conclusiones](#conclusiones)
5. [Referencias](#referencias)

## Diseño implementado


### Descripción
En este laboratorio se diseñó e implementó una Unidad Aritmético-Lógica (ALU) secuencial de 6 bits, capaz de ejecutar cinco operaciones principales: suma, resta, multiplicación, desplazamiento a la izquierda y operación lógica NOT.

El diseño recibe dos operandos de 4 bits (A y B) y un código de operación de 3 bits (op) que determina la función a realizar. Además de la salida principal de la operación (Y), la ALU genera dos señales de estado:

Zero, que se activa cuando el resultado de la operación es igual a cero.

Overflow, que indica la ocurrencia de un desbordamiento o pérdida de bits significativos en operaciones aritméticas o de desplazamiento.

La arquitectura se basa en una máquina de estados secuencial que controla el flujo de las operaciones contenidad en modulos independientes que son instanciados en el principal. En el caso de las operaciones combinacionales (suma, resta, NOT y desplazamiento), el resultado se obtiene de manera inmediata. Para la multiplicación, en cambio, se implementa un módulo secuencial que requiere varios ciclos de reloj para completar el cálculo, generando una señal de control (done) al finalizar.

### Estados de la maquina de estados:

#### 1. Estado 1: INACTIVO
Es el estado de reposo. La ALU espera a que se active la señal `start`.

Aciones: 

- `done=0`
- `Y`, `Zero` y `Overflow` se mantienen o se limpian (cuando se realiza una nueva operación).
- Si `start=1` se evalua el valor de `op` para decidir la operacion.

Transiciones: 
- Si `op` corresponde a una operación combinacional (`SUMA`, `RESTA`, `NOT`, `CORRIMIENTO`):
  Se realiza la operación en el mismo ciclo y se pasa directamente a `FINALIZADO`.
- Si `op=3b'001` (MULTIPLICACIÓN):
  La operación se ejecuta de forma secuencial, pasando al estado `PROCESANDO`.


#### 2. Estado 2: PROCESANDO

Este estado controla la multiplicación secuencial, la única operación que toma varios ciclos.

Acciones:

- Se mantiene activa la señal `start` hacia el módulo `multiplier_4bit_asm`.
- La ALU espera a que la señal `mult_done` del multiplicador cambie a `1`, indicando que el cálculo terminó.

Transiciones:
- Cuando `mult_done = 1`, la ALU:
  - Carga `Y = mult_result[5:0]`
  - Calcula `Overflow = |mult_result[7:6]`
  - Calcula `Zero = (mult_result[5:0] == 6'd0)`
  - Pasa al estado `FINALIZADO`.





#### 3. Estado 3: FINALIZADO 

Indica que la operación (sea combinacional o secuencial) ya se completó.

Acciones:

- `done = 1` → Señal de finalización activa.
- Las salidas `Y`, `Zero` y `Overflow` mantienen el resultado estable.
- No se realiza ningún cálculo nuevo.

Transiciones:

- Cuando `start` vuelve a `0`, el sistema retorna a `INACTIVO` para permitir una nueva operación.

### Codificación del selector de operaciones

| Codificación | Operación |
|------------|------------|
| op: 000 | Suma |
| op: 001 | Multiplicación |
| op: 010 | Resta |
| op: 011 | NOT |
| op: 100 | Desplazamiento |


### Diagrama

A continuación se puede observar el diagrama de flujo del modulo principal denominado "ALU":

<img src="/Imagenes/diagrama.png" alt="diagrama" width="80%">

## Simulaciones 

A continuación, se muestran los diferentes casos que se simularon para corroborar el correcto funcionamiento del modulo de la ALU. En la carpeta "src" se encuentra el Testbench empleado para la simulación en gtkwave.

En la primera imagen se pueden observar las tres señales más importantes: ``A``, ``B`` y ``Y`` expresadas a través de su notación en números binarios mientras que la segunda refleja la misma información que la primera, excepto que esas mismas tres señales ahora se ven mediante su equivalencia en números decimales; esto para tener una mejor comprensión de los valores de entrada.

<img src="/Imagenes/Simulacion-B.JPG" alt="Simu-1" width="90%">

En la imagen anterior se puede apreciar los números binarios de 4 bits, los cuales fueron las entradas de la ALU, ``A`` y ``B``. Asimismo, la salida en general de la ALU de 6 bits ``Y``, la señal de ``Overflow``, ``Zero``, ``start`` y ``done``, por último el selector ``op`` el cual se expresa en números decimales. Para tener una mayor claridad estas son las operaciones que se relacionan con cada estado de ``op``:

- op = 0 --> Suma
- op = 1 --> Multiplicación
- op = 2 --> Resta
- op = 3 --> NOT
- op = 4 --> Corrimiento a la izquierda

Por otro lado, se va a profundizar en la explicación de operación NOT y el corrimiento a la izquierda en esta simulación debido a que es mucho más facil explicarlo con números binarios. Cuando op = 3 se puede ver que el número A está en 1010 y el número B en 0000, esto porque la operación lógica solamente se le aplicará al número A por practicidad, al presionarse ``start`` se efectúa esta operación dando como resultado una salida Y = 000101, lo cual demuestra que la inversión lógica se realizó de manera correcta; la señal de done se "enciende" cuando la operación finaliza. Luego, el siguiente estado es op = 4 a su vez A es 0011 y B es 0010, después de que se presiona start la salida Y reporta un valor de 001100, esto muestra que el corrimiento del número A en función de B se llevo acabo correctamente, ya que A se desplazó a la izquierda dos posiciones.

<img src="/Imagenes/Simulacion-D.JPG" alt="Simu-2" width="90%">

Por medio de la anterior imagen se va a explicar el caso de la suma, la multiplicación, la resta, cuando hay Overflow y cuando hay Zero.
La primera operación que se puede ver es la suma porque op = 0

## Implementación

A continuación se puede observar el vídeo mostrando y explicando el correcto funcionamiento de la FPGA según lo requerido en la guía de laboratorio.

[Vídeo explicando el funcionamiento](https://youtu.be/yUS4pviFKPc)

## Conclusiones

* Se implementó una ALU capaz de operar con datos de 4 bits, realizando operaciones básicas como suma, resta, multiplicación, corrimiento y una operación lógica seleccionada (NOT). Esto permitió comprender cómo se estructuran estas unidades dentro de un procesador y cómo se diseñan utilizando un lenguaje de descripción de hardware (HDL).

* Además, se profundizó en el uso de un multiplexor como mecanismo de selección de operaciones, aspecto esencial en la arquitectura de una ALU. Esto permitió observar cómo, dependiendo de señales de control, la unidad puede cambiar su comportamiento dinámicamente, ofreciendo distintas salidas según la operación solicitada.

* Otro punto clave fue comprender la función de la ALU dentro de la microarquitectura del procesador. Se identificó que la ALU constituye el núcleo del procesamiento de datos, siendo la encargada de ejecutar instrucciones aritméticas y lógicas fundamentales para el funcionamiento general del sistema. Su correcta integración con los demás bloques funcionales permite ejecutar programas y operaciones complejas.

* Durante la etapa de implementación física en la placa de desarrollo, se presentó un inconveniente importante: al ejecutar las operaciones, no se reflejaban resultados en los LEDs de salida, ni en las señales de Overflow o Zero, mostrando únicamente la señal ``done``. Tras un análisis prolongado sin éxito, se descubrió finalmente que el problema radicaba en **una mala ubicación del bloque ``case`` encargado de seleccionar la operación** (``op``), el cual estaba dentro de un bloque de lógica combinacional, sin sincronización con el reloj. Esto impedía que el sistema actualizara correctamente su estado, ya que el flujo de control principal dependía de una máquina de estados implementada en un bloque secuencial.
Este error, aunque frustrante, fue una experiencia valiosa, ya que permitió reforzar la importancia de **estructurar adecuadamente la lógica secuencial y combinacional** en sistemas digitales, especialmente cuando se combinan operaciones síncronas (como la multiplicación mediante ASM) con operaciones combinacionales simples. Finalmente, al reubicar correctamente la lógica de control dentro del bloque sincronizado con el reloj, el diseño funcionó como se esperaba, validando todo el sistema.

## Referencias

Guía de laboratorio sobre la ALU: [Unidad Aritmético-Lógica (ALU)](https://github.com/jharamirezma/Lab_electronica_digital_2/blob/main/labs/lab02/README.md)
