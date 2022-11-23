.data

address1: 	.asciiz "D:\sami\data.231020221943"
address2: 	.asciiz "D:\sami\Parsing_Rules.config"
buffer1: 	.space	40800
buffer2:	.space	1200
text1:		.asciiz "D:\sami\Alerts_Triggered.log"
text2:		.asciiz "D:\sami\Report.log"
Ips:		.space  3000	#Arreglo de Ips
Usernames:	.space	1600	#Arreglo de Usernames
Dates:		.space 	2400	#Arreglo de Dates
IpAlerts:	.space  300	#Arreglo de alertas de Ips
UsernameAlerts: .space  160	#Arreglo de alertas de Usernames
Output:         .asciiz "Este archivo contiene los reportes de alertas en el Programa:"
BusQueda:	.asciiz " "	#Username o Id a buscar en los logs 
str_data: 	.asciiz "El elemento se encuentra en los Logs!"
str_data_end:   

.text
main:
    la  $t0, Dates          # Copy the base address of your array into $t0
    add $t0, $t0, 2400      # 12 bytes per int * 200 ints = 2400 bytes                              
outterLoop:                 # Used to determine when we are done iterating over the Array
    add $t1, $0, $0         # $t1 holds a flag to determine when the list is sorted
    la  $a3, Dates          # Set $a0 to the base address of the Array Dates
    la  $a1, Ips      	    # Set $a1 to the base address of the Array Ips
    la  $a2, Usernames      # Set $a2 to the base address of the Array Usernames
innerLoop:                  # The inner loop will iterate over the Array checking if a swap is needed
    lw  $t5, 0($a1)         # sets $t0 to the current element in array Ips
    lw  $t2, 0($a3)         # sets $t0 to the current element in array Dates
    lw  $t6, 0($a2)         # sets $t0 to the current element in array Usernames
    lw  $t3, 12($a3)        # sets $t1 to the next element in array Dates
    lw $t7, 15($a1)        # sets $t1 to the next element in array Ips
    lw  $t8, 8($a2)        # sets $t1 to the next element in array Usernames
    slt $t4, $t2, $t3       # $t4 = 1 if $t0 < $t1
    beq $t4, $0, continue   # if $t4 = 1, then swap them
    add $t1, $0, 1          # if we need to swap, we need to check the list again
    sb  $t2, 12($a3)         # store the greater numbers contents in the higher position in array Dates(swap)
    sb  $t3, 0($a3)         # store the lesser numbers contents in the lower position in array Dates(swap)
    sb  $t5, 15($a1)         # store the greater numbers contents in the higher position in array Ips(swap)
    sb  $t7, 0($a1)         # store the lesser numbers contents in the lower position in array Ips (swap)
    sb  $t6, 8($a2)         # store the greater numbers contents in the higher position in array Usernames(swap)
    sb  $t8, 0($a2)         # store the lesser numbers contents in the lower position in array Usernames(swap)
continue:
    addi $a3, $a3, 12            # advance the array Dates to start at the next location from last time
    addi $a1, $a1, 15            # advance the array Ipsto start at the next location from last time
    addi $a2, $a2, 8            # advance the array Usernames to start at the next location from last time     
    bne  $a3, $t3, innerLoop    # If $a0 != the end of Array, jump back to innerLoop
    bne  $t1, $0, outterLoop    # $t1 = 1, another pass is needed, jump back to outterLoop    
eliminarUsernamesRepetidos:
	la $t1, UsernameAlerts  				
	la $t2, UsernameAlerts					
	la $t3,	UsernameAlerts    
	li $t4, 0					#setting $t4 = 0; t4 will serve as a counter
	li $s1, 20					#setting $s1 = 20
for:							#for(int i = 0; i<array.length; i++)
	beq $t4, $s1, compareips
	lw $t5, 0($t1)					#get value from array cell and store in $t5
	lw $t6, 0($t2)					#get value from array cell and store in $t5
	addi $t4, $t4, 12
	bne $t5,$t6 for
for1:
	Subu $t9, $s1, 1
	beq $t4, $t9, compareips
	lw $t7, 1($t3)
	subu $s1, $s1, 1 
	j for1
compareips:
    la $t2, Ips 				#$t2 = address of Ips
    la $t3, IpAlerts				#$t3 = address of IpAlerts
    li $t0, 200 				#$t0 = maximun number of elements in the first loop 
    li $s0, 0 		                        #$s0 = holds a counter to determine when the loop is finished 
    la $t4, Usernames 				#$t2 = address of Usernames
    la $t5, Dates  				#$t2 = address of Dates
loop1:
    beq $s0, $t0, compareusernames 	        # if s0 == 200 we are done
    li $t1, 20					#$t1 = maximun number of elements in the second loop  
    li $s1, 0					#$s1 = holds a counter to determine when the loop is finished 
loop2:
    beq $s1, $t1, loop1 		        # if t2 == 20 we are done
loopbody:
    li $a1, 15 					#load multiplier for Ips arrays,Usernames,Dates
    mul $s0 $s0 $a1				#moves the arrays for Ips arrays
    mul $s1 $s1 $a1				#moves the arrays for Ips arrays
    add $t4 $t5 $s0
    add $t4 $t5 $s0
    add $t2 $t2 $s0
    add $t3 $t3 $s1
    lw $t5 ($t5)
    lw $t4 ($t4)
    lw $t2 ($t2)
    lw $t3 ($t3)
    bne $t2 $t3 seguir   
file_open:
    li $v0, 13
    la $a0, text1
    li $a1, 1
    li $a2, 0
    syscall  # File descriptor gets returned in $v0
file_write:
    move $a0, $v0  # Syscall 15 requieres file descriptor in $a0
    li $v0, 15
    la $a1, Output
    la $a2, str_data_end
    la $a3, Output
    subu $a2, $a2, $a3  # computes the length of the string, this is really a constant
    la $a1, ($t4)
    la $a2, str_data_end
    la $a3, ($t4)
    subu $a2, $a2, $a3  # computes the length of the string, this is really a constant
    la $a1, ($t5)
    la $a2, str_data_end
    la $a3, ($t5)
    subu $a2, $a2, $a3  # computes the length of the string, this is really a constant
    la $a1, ($t2)
    la $a2, str_data_end
    la $a3, ($t2)
    subu $a2, $a2, $a3  # computes the length of the string, this is really a constant
    syscall
file_close:
    li $v0, 16  # $a0 already has the file descriptor
    syscall         
seguir:
    addi $t1, $t1, 1 # add 1 to t1
    j loop2 # jump back to the top
    addi $t1, $t1, 1 # add 1 to t1
    j loop1 # jump back to the top

compareusernames:
    la $t2, Ips 				#$t2 = address of Ips
    la $t3, UsernameAlerts				#$t3 = address of IpAlerts
    li $t0, 200 				#$t0 = maximun number of elements in the first loop 
    li $s0, 0 		                        #$s0 = holds a counter to determine when the loop is finished 
    la $t4, Usernames 				#$t2 = address of Usernames
    la $t5, Dates  				#$t2 = address of Dates
loop3:
    beq $s0, $t0, Report	        # if s0 == 200 we are done
    li $t1, 20					#$t1 = maximun number of elements in the second loop  
    li $s1, 0					#$s1 = holds a counter to determine when the loop is finished 
loop4:
    beq $s1, $t1, loop3 		        # if t2 == 20 we are done
lopbody:
    li $a1, 15 					#load multiplier for Ips arrays,Usernames,Dates
    mul $s0 $s0 $a1				#moves the arrays for Ips arrays
    mul $s1 $s1 $a1				#moves the arrays for Ips arrays
    add $t4 $t5 $s0
    add $t4 $t5 $s0
    add $t2 $t2 $s0
    add $t3 $t3 $s1
    lw $t5 ($t5)
    lw $t4 ($t4)
    lw $t2 ($t2)
    lw $t3 ($t3)
    bne $t4 $t3 contine   
file_pen:
    li $v0, 13
    la $a0, text1
    li $a1, 1
    li $a2, 0
    syscall  # File descriptor gets returned in $v0
file_wite:
    move $a0, $v0  # Syscall 15 requieres file descriptor in $a0
    li $v0, 15
    la $a1, Output
    la $a2, str_data_end
    la $a3, Output
    subu $a2, $a2, $a3  # computes the length of the string, this is really a constant
    la $a1, ($t4)
    la $a2, str_data_end
    la $a3, ($t4)
    subu $a2, $a2, $a3  # computes the length of the string, this is really a constant
    la $a1, ($t5)
    la $a2, str_data_end
    la $a3, ($t5)
    subu $a2, $a2, $a3  # computes the length of the string, this is really a constant
    la $a1, ($t2)
    la $a2, str_data_end
    la $a3, ($t2)
    subu $a2, $a2, $a3  # computes the length of the string, this is really a constant
    syscall
file_cose:
    li $v0, 16  # $a0 already has the file descriptor
    syscall         
contine:
    addi $t1, $t1, 1 # add 1 to t1
    j loop3 # jump back to the top
    addi $t1, $t1, 1 # add 1 to t1
    j loop4 # jump back to the top
Report:
    ori $t0, $0, 0x0   # Initialize index with 0
    la $t4, Usernames 
LOOP:  
    beq $t0,200,Final 	
    lw $t1, ($t4)   #($t0)  # We use the label name instead of the actual constant
    lw $t2, BusQueda
    beq $t1,$t2,Encounter 
    addi $t0, $t0, 4   # Increment index by 4
    j LOOP
Encounter:
    li $v0, 13
    la $a0, text2
    li $a1, 1
    li $a2, 0
    syscall  # File descriptor gets returned in $v0
file_wri:
    move $a0, $v0  # Syscall 15 requieres file descriptor in $a0
    li $v0, 15
    la $a1, str_data
    la $a2, str_data_end
    la $a3, str_data
    subu $a2, $a2, $a3  # computes the length of the string, this is really a constant
    syscall
file_clo:
    li $v0, 16  # $a0 already has the file descriptor
    syscall
    j LOOP	
Final:	
    li $v0, 10  # $a0 already has the file descriptor
    syscall	
	
	
	
	
	
	
	
	
