# MIPS-DLX Processor
---
This is the final project for the Computers Architecture subject of the Computer Engineering degree.


## Software

This project was developed using Xilinx Vivado 2023.1 with legacy boards support enabled using
https://github.com/Digilent/vivado-boards

## File tree

```
.
├── Behaviours
├── GUI
├── constraints
├── src
|    ├── debug unit
|    ├── pipeline
|    └── uart
├── sim
└── Readme.md
```

## GUI

The MIPS-DLX GUI provides a user-friendly interface for interacting with a MIPS-DLX system using a UART (Universal Asynchronous Receiver/Transmitter) connection.

### Requirements

Before running the script, make sure to have the following libraries installed:

```bash
pip install tkinter
pip install pyserial
```

### Step-by-Step Usage

1. Select UART Port:
-  Open the application and choose the UART port and baudrate.
-  Click "Select Port."

  ![GUI Image](https://github.com/FranciscoCross/MIPS-DLX/blob/main/img/gui/image.png)
  
2. Choose Instruction File:
-  After selecting the port, a new window will appear. Select an assembly language instruction file.
3. Compile:
-  Click the "Compile" button to convert the assembly code into machine instructions. The compiled code will be displayed on the right.
4. Send Program:
-  Click "Send Program" to transmit the compiled instructions to the MIPS-DLX system via UART.

  ![GUI Image](https://github.com/FranciscoCross/MIPS-DLX/blob/main/img/gui/image1.png)

##### Additional
1. Get Information:
-  Click "Get Information" to retrieve system information. Note that this button works only if the program has not been sent to the system.

 ![GUI Image](https://github.com/FranciscoCross/MIPS-DLX/blob/main/img/gui/image3.png)

#### Execution modes

1. Continuous Execution:
-   Click "Continuous Execution" to run the program continuously on the system.

2. Step-by-Step Execution:
-   Click "Step-by-Step Execution" to execute the program one step at a time.
      
 ![GUI Image](https://github.com/FranciscoCross/MIPS-DLX/blob/main/img/gui/image4.png)

## References

* Computer Architecture a Quantitative Approach - Hennesy & Patterson
* Computer Organization and Desing - Hennesy & Patterson
