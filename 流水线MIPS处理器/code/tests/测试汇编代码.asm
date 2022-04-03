.data 
  in_buff:.space 32 #0x00000000��ʼ0x0000-007c
  cache_ptr:.space 32 #0x0000-0080��0x0000-00fc
.text 0x00400000
main:
la $s1 0x4000001C#���ڽ�������UART_RXD
la $s2 0x40000020#����UART_CON
la $s0 in_buff#���datamemory

U_RECV1:lw $t0,0($s1) #���ڽ�������UART_RXD
bltz $t0, U_RECV1
lw $t1,0($s2) #����UART_CON
sw $t0 0($s0) #�����������datamemory
U_RECV2:lw $t2,0($s1) #���ڽ�������UART_RXD
bltz $t2, U_RECV2
lw $t1,0($s2) #����UART_CON
sw $t2,4($s0) #��item_num��datamemory,t2=item_num,���жϺ�ʱ������ȡ
addi $s0,$s0,8
add $t3,$t2,$t2#t3=2* item_num

UART: lw $t0,0($s1) #���ڽ�������UART_RXD
bltz $t0, UART
sw $t0 0($s0) #���datamemory
subi $t3 $t3 1#��Ҫ�������һ
beq $t3,$0,MAIN
addi $s0,$s0,4#��ַ��һ
lw $t1,0($s2) #����UART_CON
j UART

MAIN:la $s0 in_buff
lw $t0,0($s0)#t0 is knapsack_capacity �������
lw $t1,4($s0)#t1 is item_num
addi $s0,$s0,8#item_list is 8 byte ��Ʒ������׵�ַ ��Ʒ����������ַ+4=��Ʒ�����ֵ��ַ
la $s1,cache_ptr#cache_ptr[] ������һ��������,��in_buff����
addi $s2,$zero,0#$s2 is i
JUDGE_FOR1:beq $s2,$t1,END_FOR1#t1 is item_num
FOR1:sll $t2,$s2,3#s2 is i, t2=8*i
add $t3,$s0,$t2#t3:&item_list[i]
lw $t4,0($t3)#t4=item_list[i].weight
lw $t5,4($t3)#t5=item_list[i].value
addi $s3,$t0,0#$s3 is j int j=knapsack_capacity �������
JUDGE_FOR2:bltz $s3,END_FOR2#j<0����ѭ��
FOR2:slt $s5,$s3,$t4#j<weight s5=1
beq $s5,$0,IF
j END_IF
IF:sll $t6,$s3,2#t6=j*4
add $t7,$s1,$t6#t7 is &cache_ptr[j]
sub $t2,$s3,$t4#j-weight
sll $t2,$t2,2#(j-weight)*4
add $t8,$s1,$t2#t8 is &cache_ptr[j-weight]
lw $t2,0($t7)#t2 is cache_ptr[j]
lw $t3,0($t8)#t3 is cache_ptr[j-weight]
add $t9,$t3,$t5#t9 is cache_ptr[j - weight] + val
slt $s6,$t9,$t2#s6=1 cache_ptr[j - weight] + val<cache_ptr[j]
bne $s6,$0,IF1
j ELSE1
IF1:sw $t2,0($t7)
j END_IF
ELSE1:sw $t9,0($t7)
END_IF:subi $s3,$s3,1
j JUDGE_FOR2
END_FOR2:addi $s2,$s2,1
j JUDGE_FOR1
END_FOR1:sll $t9,$t0,2
add $s7,$s1,$t9
lw $v0,0($s7)
la $a0,0x40000010
sw $v0 0($a0)
la $a0,0x40000018

sw $v0 0($a0)
ENDJ:j ENDJ
