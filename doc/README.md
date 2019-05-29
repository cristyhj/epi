Toate caile din acest tutorial sunt date relativ la radacina proiectului de pe GitHub (https://github.com/cristyhj/epi). Pe acest computer proiectul este clonat in `D:\Andrei Marius-Cristian\ProiectGitHub`.


1. Pregatirea cardului SD

Pentru pregatirea cardului terbuiesc create pe cardul SD 2 partitii, una FAT32 (16/32 MB) si una ext4 (restul memoriei). Fiecare partitie are un set de fisiere dupa cum urmeaza:

- Boot partition (FAT32):		// prima partitie si are 16 sau 32 MB.
	- BOOT.bin			// este primul fisier care este deschis cand se booteaza dupa SD si contine urmatoarele 3 fisiere.
		- fsbl.elf		// First Sector Boot Loader se ocupa in primul rand cu incaracrea bitstream-ului in FPGA. Este generat din Xilinx SDK si este specific fiecarui proiect.
		- bitstream.bit		// este configuratia hardware din FPGA. Este generat prin Sinteza si Implementare in Vivado.
		- uboot.elf		// uboot se ocupa cu incarcarea sistemului de operare. O data compilat este bun pentru totdeauna.
	- devicetree.dtb		// este specific fiecarui proiect insa se modifica rar. Contine specificatia hardware a placutei. De exemplu, contine toate magistralele si liniile de comunicatie externa si specific pentru proiectul acesta contine 2 linii de DMA si consola pentru UART prin care te conectezi cu Putty.
	- uImage			// imaginea kernelului de linux. Un driver de linux se compileaza folosind un kernel, deci, daca vrei sa folosesti un driver compilat de tine terbuie sa compilezi si tu kernelul de linux.

- Root partition (ext4):
	- Ubuntu linaro File System	// sistemul de fisiere al linux-ului (contine cam tot ce este pus peste kernel). In general este o arhiva .tar pe care o dezarhivezi direct pe aceasta partitie.

Toate aceste fisiere deja create se afla in folderul `epi/files`.


1.1. Testarea a ceea ce functioneaza deja.

- Creaza cele 2 partitii. Daca folosesti Linux, recomand Gparted. Pentru Windows poti cauta pe internet tutoriale (how to create linux partitions using windows).
	Cele 2 partitii au urmatoarea denumire si configuratie:
	- Boot, 16 MB (sau 32 MB)
	- Root, restul memoriei cardului.
	Denumirile nu cred ca au vreo relevanta, dar nu am incercat altfel, cel putin pentru partita Boot.
- Copiaza pe partita Boot fisierele: 
	- BOOT.bin
	- devicetree.dtb
	- uImage
- Dezarhiveaza arhiva pe partitia Root. Descarca arhiva (ultimul .tar.gz) de la: `https://releases.linaro.org/archive/12.11/ubuntu/precise-images/ubuntu-desktop/`. Dezarhiveaza fisierele si copiaza-le pe partitie.
- Acum totul ar terbui sa functioneze. Pune cardul si porneste palcuta avand in vedere configuratia pinilor pentru bootarea de ep SD.

- Daca apare vreo eraore (o eroare in u-boot) incearca sa copiezi fisierul uEnv.txt pe partitia Boot si sa incerci din nou.





2. Compilarea si modificarea surselor

2.1 Compilarea kernelului de linux

Pentru compilarea kernelului de linux ai nevoie de o masina virtuala linux. Aici s-a folosit Ubuntu 18.4.

- Downloadarea kernelului:

```
> git clone https://github.com/Xilinx/linux-xlnx
```

- Instalarea dependintelor:
	- cross-compiler -ul de ARM
	- flex si bison

```
> sudo apt-get install gcc-arm*
> sudo apt-get install flex bison
> sudo apt-get install gcc
```

- Setarea variabilelor de mediu 
	(environment variables)
	(variabilele de mediu setare pentru cross compiling) 
	(`export` poate fi folosit si din interiorul unui script pentru setarea variabilelor de mediu)

```
> export ARCH=arm
> export CROSS_COMPILE=arm-linux-gnueabi-
```

- Make pentru fisierul de configurare (acest make scrie un fisier de configurare)

```
> make xilinx_zynq_defconfig
```

- Make pentru crearea imaginii uImage. Acest process dureaza mai mult.

```
> make UIMAGE_LOADADDR=0x8000 uImage
```

In momentul acesta daca alte erori nu au aparut ar terbui sa fie in folderul `linux-xlnx` un fisier fara extensie `uImage`. Acesta este imaginea kernelului.

2.2 Compilarea U-Boot

Daca instalarea dependinteleor de la pasul anterior a avut succes la acest pas nu trebuie repetata.

- Setarea variabilelor de mediu trebuie facuta din nou daca consola in care s-a lucrat a fost inchisa.
```
> export ARCH=arm
> export CROSS_COMPILE=arm-linux-gnueabi-
```

- Make pentru fisierul de configurare:
	- `zynq_zed_defconfig`  - pentru Zedboard
	- `zynq_zybo_defconfig` - pentru Zybo Z7
```
> make zynq_zed_defconfig
```
- Make pentru uBoot, se ruleaza simplu comanda make

```
> make
```





3. Proiectul Vivado

3.1. Pentru recontruirea proiectului Vivado ai nevoie de blocul custom `packet_analyzer_core` pe care il gasesti in folderul `epi\epi_vivado\repo\packet_analyzer_core`.

- Creaza un nou proiect specific placutei pe care vrei sa lucrezi (Zybo sau ZedBoard) (next next next finish)
- Creaza un nou design (Create Block Design) (ok)
- Adauga un block Zynq Processing System si apasa pe `Run Block Automation`
- Cu dublu-click pe block modificam setarile astfel:
	- PS-PL Configuration
		- HP Slave AXI Interface - se activeaza prima si se seteaza Data-Width 32
	- Peripheral I/O pins - se dezactiveaza USB 0 si TTC0
	- Clock Configuration
		- PL Fabrick Clock - se activeaza al doilea si se seteaza la viteza de 200 MHz (in total, un ceas de 100 MHz si unul de 200 MHz)
	- Interrupts
		- Fabric Interrupts - se activeaza
			- PL-PS Interrupts Port - IRQ_F2P[15:0] - se activeaza (//intreruperile sunt necesare pentru semnalizarea terminarii transferului DMA)
- Se adauga blocul custom `packet_analyzer_core`. Pentru asta mai intai se adauga Repository-ul cu blocul. Din meniul `Flow Navigator` din stanga se apasa pe `IP Catalog`. 
Apoi cu click dreapta pe fereastra nou aparuta se da `Add new Repository`.
Se selecteaza folderul `epi/epi_vivado/repo` si dupa OK ar terbui sa apara o fereastra care spune "1 repository was added to the project" si mai jos un drop down list cu IP-ul.
- Se adauga blocul in design, cautand dupa "packet_inspection". (Dupa adaugare nu se apsa `Run Connection Automation`)
- Se conecteaza `m_axis` cu `S_AXI_HP0` si cand apare o fereastra apasati OK. Dupa asta ar trebui sa se creeze inca 3 blocuri:
	- axi_dma
	- axi_mem_interconnect
	- rst_ps7_0_100M
- Se apasa pe `Run Connection Automation` si se selecteaza doar `engine_clock` iar in fereastra din dreapta se selecteaza ceasul de 200 MHz. Dupa ok se mai ceraza un block:
	- rst_ps7_0_200M
- Se apasa pe `Run Connection Automation` iar si se selecteaza tot. Dupa ok, toate conexiunile sunt facute si designul arata ca cel din proiectul final.
- Se apasa click dreapta pe `design_1` din fereastra `Sources` si se face click pe `Create HDL Wrapper` cu setarea "Let Vivado manage...".
- Se apasa pe Generate Bitstream, din partea stanga din meniul `Flow navigator` si ferestrele ce apar spun ca va rul ainainte Synteza si Implementarea.
Acest proces dureaza mai mult, daca apar erori nu prea pot fi gasite pe internet, ma poti contacta si daca te pot ajuta o voi face cu drag.

Acest pas genereaza fisieul `bitstream.bit` si poate fi exportat din meniul File > Export > Export Bitstram File


3.2. Crearea First Sector Boot Loader-ului. (fsbl.elf)

- Din Vivado, dupa ce a avut succes generearea bitstream-ului, apasati File > Export > Export Hardware, selectati include bitstream si <local project> si click ok.
- File > Lunch SDK
- Din SDK, apasa pe File > New > Application Project.
	- Project name: fsbl
	- restul ramane default
	- apasa Next
	- Selecteaza Zynq FSBL
	- Finish
- Dupa ce se creaza proiectul acesta isi face build automat si fisierul fsbl.elf va fi creat. Daca nu isi face build automat, click dreapta pe proiect > build.
- Fisierul se gaseste in proiectul vivado, folderul.sdk: `\epi_zedboard\epi_zedboard.sdk\fsbl\Debug\fsbl.elf`.










































