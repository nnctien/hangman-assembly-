# Hang Man game.


.data
	String_in_File : .space 100
	arr_score: .space 1000 
	arr_player: .space 1000 #100 phan tu 10 byte
	str: .space 1000 # 250 phan tu 4 bytes
	str_player: .space 1000	
	SeWo: .space 20	# Bien chuoi dap an (load tu file)
	title: .asciiz "=========================| HANG~MAN |========================="
	nhap: .asciiz "Xin moi nhap username: "
	nhap.err: .asciiz "Username vua nhap khong hop le. Vui long nhap lai.\n"
	player.info: .asciiz "\n================================================\nTen nguoi choi-Tong so diem-So luot chien thang\n"
	end.opt: .asciiz "\n================================================\n1. Tiep tuc tro choi\n2. Thoat\nLua chon cua ban: "
	MissTurn: .asciiz "\nSo luot da mat: "
	ques: .asciiz "\nNhap chuoi hay ky tu ban doan: "
	lose: .asciiz "\nYOU LOSE! GAME OVER!\n"
	tb2: .asciiz "\nYOU WIN! GO TO NEXT ROUND!\n"
	tt.tb:  .asciiz "\n-------------"
	tt.tb1: .asciiz "\n|/       |"
	tt.tb2: .asciiz "\n|        O"
	tt.tb3: .asciiz "\n|        |"
	tt.tb4: .asciiz "\n|       /|"
	tt.tb5: .asciiz "\n|       /|\\"
	tt.tb6: .asciiz "\n|       /"
	tt.tb7: .asciiz "\n|       / \\"
	tt.tb8: .asciiz "\n|"
	tbtest: .asciiz "Nhap de thi: "
	tb1 : .asciiz "\nTop 10 Player and score:"
	xuongdong : .asciiz"\n" 
	daucach: .asciiz "-"
	dausao: .asciiz "*"	
	
	fin: .asciiz "nguoichoi.txt"    
	fout: .asciiz "nguoichoi.txt"      # filename for output
	file_data_name: .asciiz "dethi.txt"
	
	SeC: .byte '*'
	Line: .byte '-'
	
	number_of_word: .word 0 
	lenAns: .word 0	# Do dai chuoi nguoi choi nhap
	lenSeWo: .word 0	# Do dai chuoi de thi
	Miss: .word 0		# So luot doan sai
	Diem: .word 0		# Diem nguoi choi
	WinRound: .word 0	# So luot chien thang
	randNumber: .word -1	# So random de thi
	number_of_highscore: .word 0
	
	
	Ans: .space 20	# Bien chuoi va ky tu nguoi choi nhap
	Dis: .space 20	# Bien hien thi de thi (ky tu an)	
	Diem_str: .space 20		# Diem nguoi choi (duoi dang string)
	WinRound_str: .space 20	# So luot chien thang (duoi dang string)
	player.name: .space 20	# Ten nguoi choi
	player.inf: .space 63	# Chuoi "player.name-Diem-WinRound*"
	str_playername: .space 30		# Bien tam cho ham nhap ten nguoi choi
	

	
	
		
.text
	.globl main	
	
########################### main #################################	
main:	
	#---------new player info---------
Replay:
	# nhap ten nguoi choi
	jal _EnterUsername
	
	# khoi tao
	li $a0,0
	la $a1,Diem
	sw $a0,($a1)		# Diem = 0
	
	la $a1,WinRound
	sw $a0,($a1)		# WinRound = 0
	
	#--------create new round---------
NewRound:	
	li $s0, 0		
	sw $s0, Miss	
	
	#---------create de thi-----------
	#-----generate random number------

	# lay gia tri randNumber
	la $t0,randNumber
	lw $t0,($t0)
	beq $t0,-1,RandomNum		
RandomNewNum:				# random lan choi thu n
	# goi ham Random number	
	jal _RandomNumber
	# lay ket qua tra ve
	sw $v0,randNumber
	beq $v0,$t0,RandomNewNum	# random 1 so trung voi so truoc do -> random lai
	j Exit_Random
RandomNum:				# random lan choi dau tien
	# goi ham Random number	
	jal _RandomNumber
	# lay ket qua tra ve
	sw $v0,randNumber
Exit_Random:

	#---------read from file---------- 
	jal _ReadDataFromFile	
			
	
	#------get word from POS I--------
	la $a0, String_in_File
	lw $a1, randNumber	
	jal _GetWordFromPositionI 			
	

	
	la $a0, SeWo		
	jal _LengthBuffer	# lay do dai chuoi ket thuc = $0
	sw $v0,lenSeWo
					
	la $a0, Dis
	lw $a1, lenSeWo
	jal _ConDis		# khoi tao chuoi an cua de thi

	#------------game loop------------	
GameLoop: 
	# in tieu de
	li $v0, 4
	la $a0, title
	syscall
	# in tb so luot da mat
	li $v0, 4
	la $a0, MissTurn
	syscall
	# in so luot mat
	li $v0, 1
	lw $a0, Miss
	syscall
	# in ky tu xuong dong
	li $v0, 11
	li $a0, '\n'
	syscall
	
	# in chuoi an
	li $v0, 4
	la $a0, Dis
	syscall
	
	# in gia treo co
	lw $a0, Miss
	jal _XuatTrangThai

	# kiem tra dieu kien thua
	lw $s0, Miss
	bge $s0, 7, GameOver
	
	# kiem tra dieu kien thang
	la $a0, Dis
	lw $a1, lenSeWo
	jal _CountHL
	move $s0, $v1		# so ky tu an
	
	beqz $s0, GameWin	# so ky tu an = 0 -> win
	
	# in cau hoi
	li $v0, 4
	la $a0, ques
	syscall
	
	# nhap cau tra loi
	li $v0, 8
	la $a0, Ans
	li $a1, 20
	syscall
	
	# tinh so ky tu trong cau tra loi
	la $a0, Ans
	jal _Length
	sw $v1, lenAns
	
	lw $t1, lenAns
	bgt $t1, 1, String		# so ky tu > 1 -> nguoi choi nhap chuoi
	
Char:	
	# xu ly nhap mot ky tu
	la $a0, SeWo			# dap an
	lw $a1, lenSeWo		# do dai chuoi dap an
	la $a2, Dis			# de thi duoi dang *
	lb $a3, Ans			# dap an nguoi choi 
	jal _AnsDis			# tra ve so_ky_tu_doan_dung	
	# doan dung			
	bnez $v1, Char.continue	# tiep tuc choi 
	# doan sai
	lw $s0, Miss			
	add $s0, $s0, 1		# so_lan_doan_sai ++
	sw $s0, Miss			
Char.continue:
	j GameLoop			
	
String:
	# xu ly nhap chuoi 
	la $a0, SeWo
	lw $a1, lenSeWo
	la $a2, Ans
	lw $a3, lenAns
	jal _AnsStr			
	beqz $v1, GameOver		# v1 = 0 thi thua
	b GameWin			

GameOver:
	# xuat tb thua
	li $v0, 4
	la $a0, lose
	syscall
	# xuat thong tin nguoi choi
	li $v0,4
	la $a0,player.info
	syscall 
	li $v0,4
	la $a0,player.name
	syscall 
	li $v0,11
	la $a0,'-'
	syscall
	li $v0,1
	la $a0,Diem
	lw $a0,($a0)
	syscall 
	li $v0,11
	la $a0,'-'
	syscall
	li $v0,1
	la $a0,WinRound
	lw $a0,($a0)
	syscall 
	
	#------write file nguoi choi------

	# Mo file ghi
	li $v0,13       
  	la $a0,fout     
  	li $a1,9		# 9: write-only with create and append
 	li $a2,0      	# mode is ignored
 	syscall            	# file descriptor -> $v0
  	move $s6,$v0      	# luu file descriptor 

	# chuyen Diem thanh string
	la $a0,Diem
	lw $a0,($a0)
	la $a1,Diem_str
	jal _IntToStr
	# chuyen WinRound thanh string
	la $a0,WinRound
	lw $a0,($a0)
	la $a1,WinRound_str
	jal _IntToStr
	# tao chuoi player.name-Diem-WinRound*
	la $a0,player.name
	la $a1,Diem_str
	la $a2,WinRound_str
	la $a3,player.inf
	jal _PlayerInfoStr
	
	# tinh do dai player.inf de ghi file ($a2)
	la $a0,player.inf
	jal _LengthBuffer
	move $a2,$v0
  	
  	# Ghi file
  	li $v0,15       
  	move $a0,$s6      
  	la $a1,player.inf   
  	syscall      
  	
	# Dong file 
  	li $v0,16       
  	move $a0,$s6      
  	syscall  
	
	#----------xuat top10-------------
	
	#====================Ham doc score tu file ================#
  	# Mo file doc
  	li   $v0, 13      
  	la   $a0, fin     
  	li   $a1, 0        	# 0: read, 1: write, 9: write-only with create and append
  	li   $a2, 0        	# mode is ignored
  	syscall           	# v0 <- file descriptor 
  	move $s6, $v0     	# luu vao s6
 
	# Doc file 
	li   $v0, 14       
	move $a0, $s6      	
	la   $a1, str   	
	li   $a2, 1000       	# do dai chuoi doc
	syscall         
	#truyen vao string_file , arr_score
	#tra ve number of highscore
	# truyen tham so
	la $a0,arr_score
	la $a1,str
	# goi ham
	jal _TachChuoilayScore
	# lay kq tra ve so luong highscore
	
	sw $v0, number_of_highscore
	
	
	# Close file 
 	li   $v0, 16       
  	move $a0, $s6      # file descriptor to close
  	syscall            # close file
  	#====================Ham doc score tu file ================#
  	
  	#====================Ham doc player tu file ================#
  	# Mo file doc
  	li   $v0, 13      
  	la   $a0, fin     
  	li   $a1, 0        	# 0: read, 1: write, 9: write-only with create and append
  	li   $a2, 0        	# mode is ignored
  	syscall           	# v0 <- file descriptor 
  	move $s6, $v0     	# luu vao s6
 
	# Doc file 
	li   $v0, 14       
	move $a0, $s6      	
	la   $a1, str   	
	li   $a2, 1000       	# do dai chuoi doc
	syscall      
	   
	#truyen vao string_file , arr_score
	#tra ve number of highscore
	# truyen tham so
	la $a0,arr_player
	la $a1,str
	# goi ham
	jal _TachChuoilayPlayer
	
	# Close file 
 	li   $v0, 16       
  	move $a0, $s6      # file descriptor to close
  	syscall            # close file				
  	#====================Ham doc player tu file ================#
  	
  	
  	#====================Ham xuat arr_Player===============#
	#truyen vao arr_score , n
	
	# truyen tham so
	lw $a0,number_of_highscore
	la $a1,arr_player
	
	#debug
	
	# goi ham
	#jal _XuatMangPlayer
  	#==================== Ham xuat arr_Player ================#
  	
  	#====================Ham xuat arr_score ================#
	#truyen vao arr_score , n
	
	# truyen tham so
	lw $a0,number_of_highscore
	la $a1,arr_score
	#debug
	#lw $a0,($a1)
	#li $v0,1
	#syscall
	# goi ham
	#jal _XuatMangInt
  	#==================== Ham xuat arr_score ================#
  	
  	#==================== Ham Sort arr_score and player================#
	#truyen vao arr_score , n
	
	# truyen tham so
	lw $a0,number_of_highscore
	la $a1,arr_score
	#deubg
	#lw $a0,($a1)
	#li $v0,1
	#syscall
	# goi ham
	jal _Sort
	  #truyen tham so
    	lw $a0,number_of_highscore
	la $a1,arr_score
    
    	#goi ham xuat mang
    	#jal _XuatMangInt
  	#====================Ham Sort arr_score and player================#
  	
  	
  	
	
	#====================Ham xuat arr_Player===============#
	#truyen vao arr_score , n
	
	# truyen tham so
	lw $a0,number_of_highscore
	la $a1,arr_player
	
	#debug
	
	# goi ham
	#jal _XuatMangPlayer
  	#==================== Ham xuat arr_Player ================#
  	
  	#====================Ham xuat arr_score ================#
	#truyen vao arr_score , n
	
	# truyen tham so
	lw $a0,number_of_highscore
	la $a1,arr_score
	
	#lw $a0,($a1)
	#li $v0,1
	#syscall
	# goi ham
	#jal _XuatMangInt
  	#==================== Ham xuat arr_score ================#
  	
  	#====================Top 10 player and score =================#
  	#xuat thong bao
  	la $a0,tb1
  	li $v0,4
  	syscall
  	# truyen tham so
	lw $a0,number_of_highscore
	#goi ham
	jal _XuatTop10
  	#====================Top 10 player and score =================#
	
	
	
	#-------lua chon nguoi choi-------
	
	# xuat tb chon
	li $v0,4
	la $a0,end.opt
	syscall
	# nhap lua chon
	li $v0,5
	syscall
	
	beq $v0,1,Replay	# tiep tuc choi
	bne $v0,1,end		# thoat
	
GameWin:
	# reset Dis
	la $a0, Dis
	lw $a1, lenSeWo
	jal _spcDis
	# xuat tb thang
	li $v0, 4
	la $a0, tb2
	syscall	
	# cong diem
	la $a0,lenSeWo
	lw $a1,($a0)
	la $a0,Diem
	lw $a2,($a0)
	add $a2,$a2,$a1
	sw $a2,Diem	
	# tang so luot chien thang
	la $a0,WinRound
	lw $a0,($a0)
	addi $a0,$a0,1
	sw $a0,WinRound
	
	j NewRound
	
	#------------end game-------------
end:	
	li $v0, 10
	syscall
	
####################### end of main ##############################


#=============== Thu tuc _Length ====================
# Tinh do dai chuoi (ket thuc bang '\n')
# Truyen vao: a0 = $str
# Tra ve: v1 = do dai str
_Length:
	add $sp, $sp,-20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	sw $t2, 16($sp)
	
	move $s0, $a0
	
	#khoi tao 
	li $t0, 0		# i = 0
_Length.loop:
	add $t2, $s0, $t0 	# $str + i
	lb $t1, ($t2)		# lay gia tri $str
	beq $t1, '\n', _Length.end	
	add $t0, $t0, 1	# i ++
	j _Length.loop
_Length.end:
	add $v1, $t0, 0	# return i
	
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	lw $t2, 16($sp)
	
	addi $sp, $sp, 20
	jr $ra
#=============== end of _Length =====================


#============= Thu tuc _LengthBuffer ================
# Tinh do dai chuoi (ket thuc bang $0)
# Truyen vao: a0 = $str
# Tra ve: v0 = do dai str
_LengthBuffer:
	addi $sp,$sp,-16
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $t0,8($sp)
	sw $t1,12($sp)
	
	move $s0,$a0
	
	li $t0,0		# i = 0
_LengthBuffer.loop:
	lb $t1,($s0)	
	beq $t1,$0,_LengthBuffer.end
	add $t0,$t0,1		# i ++	
	add $s0,$s0,1	
	j _LengthBuffer.loop
_LengthBuffer.end:
	move $v0,$t0		# return i
	
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	addi $sp, $sp, 16
	jr $ra
#============= end of _LengthBuffer =================


#=============== Thu tuc _ConDis ====================
# Ham khoi tao an cau (luu de thi duoi dang *)	
# Truyen vao: a0: Dis(hien thi ky tu an); a1: lenSeWo(do dai chuoi de thi)
# Tra ve: khong co
_ConDis:
	add $sp, $sp, -24
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	
	move $s0, $a0
	move $s1, $a1
	
	# khoi tao
	li $t0, 0		# i = 0
	lb $t2, SeC		# '*'
_ConDis.loop:
	bge $t0, $s1, _ConDis.end	# i >= lenSeWo thi end
	add $t1, $t0, $s0		# t1 = $Dis + i
	sb $t2, ($t1)			# [t1] = '*' 
	add $t0, $t0, 1		# i ++
	j _ConDis.loop
_ConDis.end:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	
	add $sp, $sp, 24
	jr $ra
#=============== end of _ConDis =====================	
	

#================ Thu tuc _AnsDis ===================
# Xu ly ky tu nguoi choi nhap vao
# Truyen vao: a0: SeWo(dap an); a1: lenSeWo(do dai de thi); a2: Dis(de thi duoi dang *); a3: Ans(dap an nguoi choi) 
# Tra ve: v1 = so ky tu doan dung
_AnsDis:
	add $sp, $sp, -40
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $t0, 20($sp)
	sw $t1, 24($sp)
	sw $t2, 28($sp)
	sw $t3, 32($sp)
	sw $t4, 36($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# khoi tao
	li $t0, 0	# i = 0
	li $t4, 0	# so_ky_tu_doan_dung = 0
_AnsDis.loop:
	bge $t0, $s1, _AnsDis.end	# i >= lenSeWo thi end
	add $t1, $s0, $t0		# t1 = $SeWo + i
	lb $t3, ($t1)			# t3 = [t1]
	add $t2, $s2, $t0		# t2 = $Dis + i
	bne $s3, $t3, _AnsDis.loop.continue	# $Ans != t3 thi lap (!= dap_an[i])
	sb $s3, ($t2)			# t2 = [$Ans] -> hien thi dap an neu nguoi choi doan dung
	add $t4, $t4, 1		# so_ky_tu_doan_dung ++
 _AnsDis.loop.continue:
	add $t0, $t0, 1		# i ++
	j _AnsDis.loop
	
_AnsDis.end:	
	move $v1, $t4			# return j
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $t0, 20($sp)
	lw $t1, 24($sp)
	lw $t2, 28($sp)
	lw $t3, 32($sp)
	lw $t4, 36($sp)
	
	addi $sp, $sp, 40
	jr $ra
#================ end of _AnsDis ====================


#================ Thu tuc _AnsStr ===================
# So sanh chuoi nguoi choi nhap voi ket qua
# Truyen vao: a0: SeWo(dap an); a1: lenSeWo(do dai de thi); a2: Ans(dap an nguoi choi); a3: lenAns(do dai dap an nguoi choi) 
# Tra ve: v1 = 0 thi thua
_AnsStr:
	add $sp, $sp, -40
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $t0, 20($sp)
	sw $t1, 24($sp)
	sw $t2, 28($sp)
	sw $t3, 32($sp)
	sw $t4, 36($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# lenSeWo = lenAns
	beq $s1, $s3, _AnsStr.le	# check dung sai
	
	# khoi tao
	li $v1, 0			# win: false
	
	# doan sai
	j _AnsStr.end			
_AnsStr.le:
	li $t0, 0			# i = 0
_AnsStr.loop:
	li $v1, 1			# win: true
	bge $t0, $s1, _AnsStr.end	# i >= lenSeWo thi thoat
	add $t1, $s0, $t0		# t1 = $SeWo + i
	lb $t3, ($t1)			# t3 = [t1]
	add $t2, $s2, $t0		# t2 = $Ans + i
	lb $t4, ($t2)			# t4 = [t2]
	bne $t3, $t4, _AnsStr.nec	# t3 != t4 -> thua
	add $t0, $t0, 1		# i ++
	j _AnsStr.loop
_AnsStr.nec:
	li $v1, 0			# win: false
_AnsStr.end:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $t0, 20($sp)
	lw $t1, 24($sp)
	lw $t2, 28($sp)
	lw $t3, 32($sp)
	lw $t4, 36($sp)	
	addi $sp, $sp, 40
	jr $ra
#================ end of _AnsStr ====================

		
#============= Thu Tuc _CountHL =====================
# Dem con bao nhieu ky tu an
# Truyen vao: a0: Dis(bien hien thi ky tu an); a1: lenSeWo(do dai chuoi de thi)
# Tra ve: v1 = so ky tu chua doan 
_CountHL:
	add $sp, $sp, -32
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)	
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	sw $t4, 28($sp)
	
	move $s0, $a0
	move $s1, $a1
	
	# khoi tao
	li $t0, 0		# i = 0
	li $t4, 0		# ky_tu_an = 0
	lb $t2, SeC		# '*'
_CountHL.loop:
	bge $t0, $s1, _CountHL.end		# i >= lenSeWo thi end
	add $t1, $s0, $t0			# t1 = $Dis +  i
	lb $t3, ($t1)				# t3 = [t1]
	bne $t2, $t3, _CountHL.loop.continue	# t3 != '*' thi tang dem
	add $t4, $t4, 1			# ky_tu_an ++
_CountHL.loop.continue:
	add $t0, $t0, 1	# i ++		
	j _CountHL.loop
_CountHL.end: 
	move $v1, $t4		# return ky_tu_an
	
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)	
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	lw $t3, 24($sp)
	lw $t4, 28($sp)
	
	addi $sp, $sp, 32
	jr $ra
#================ end of _CountHL ===================

	
#================ Thu tuc _spcDis ===================
# Lam trong chuoi Dis
# Truyen vao: $a0: Dis, $a1: lenSeWo
# Tra ve: khong
_spcDis:
	add $sp, $sp, -24
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	
	move $s0, $a0
	move $s1, $a1
	
	li $t0, 0
	li $t2, 0
_spcDis.loop:
	bge $t0, $s1, _spcDis.end
	add $t1, $s0, $t0
	sb $t2, ($t1)
	add $t0, $t0, 1
	b _spcDis.loop
_spcDis.end:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	
	add $sp, $sp, 24
	jr $ra
#================ end of _spcDis ====================

						
#============== Thu tuc _IntToStr ===================
# Chuyen so nguyen thanh chuoi
# Truyen vao: a0 = int, a1 = $string 
# Tra ve: khong
_IntToStr:
 	addi $sp,$sp,-32
 	sw $ra,($sp)
 	sw $s0,4($sp)		
 	sw $s1,8($sp)
 	sw $t0,12($sp)
 	sw $t1,16($sp)
 	sw $t2,20($sp)
 	sw $t3,24($sp)
 	sw $t4,28($sp)
 	
 	move $s0,$a0		# n
 	move $s1,$a1		# $n_str
 	
 	# khoi tao
 	li $t0,1		# i = 1: so chu so
 	li $t1,1		# j = 1
 	li $t2,10		# 10
DemSoChuSo.Loop:
 	div $s0,$t1		# n / j
 	mflo $t3		# thuong
 	mfhi $t4		# so du
 	blt $t3,10,LayGiaTri.Loop		# thuong < 10 -> end	
 	j DemSoChuSo.TangDem
DemSoChuSo.TangDem:
	add $t0,$t0,1		# i ++
	mult $t1,$t2		# j*10
 	mflo $t1
	j DemSoChuSo.Loop
LayGiaTri.Loop: 				
 	div $s0,$t1		# n / j
 	mflo $t3		# thuong
 	mfhi $s0		# so du
 	
 	# convert thuong thanh ascii
 	addi $t3,$t3,48
 	# luu thuong vao n_str
 	sb $t3,($s1)
 	
 	# neu j = 1 thi thoat
 	beq $t1,1,LayGiaTri.Thoat
 	
 	addi $s1,$s1,1	# tang dia chi
 	
 	div $t1,$t2		# j /= 10
 	mflo $t1
 
 	j LayGiaTri.Loop
 	
LayGiaTri.Thoat:	
 	lw $ra,($sp)
 	lw $s0,4($sp)		
 	lw $s1,8($sp)
 	lw $t0,12($sp)
 	lw $t1,16($sp)
 	lw $t2,20($sp)
 	lw $t3,24($sp)
 	lw $t4,28($sp)
	addi $sp,$sp,32
	jr $ra
#================ end of _IntToStr ==================						


#============ Thu tuc _PlayerInfoStr ================
# Tao chuoi thong tin nguoi choi ($player.inf)
# Truyen vao: a0 = $player.name, a1 = $Diem, a2 = $WinRound, a3 = $player.inf 
# Tra ve: khong
_PlayerInfoStr:
 	addi $sp,$sp,-36
 	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $s2,12($sp)
	sw $s3,16($sp)
 	sw $t0,20($sp)
 	sw $t1,24($sp)
 	sw $t2,28($sp)
 	sw $t3,32($sp)
 	
 	move $s0,$a0		# $player.name
 	move $s1,$a1		# $Diem
 	move $s2,$a2		# $WinRound
 	move $s3,$a3		# $player.inf
 	
 	# khoi tao
	li $t0,0		# i = 0
	
	la $t2,SeC
	lb $t2,($t2)		# '*'
	la $t3,Line
	lb $t3,($t3)		# '-'
	
	# ghi ten nguoi choi		
_PlayerInfoStr.PlayerName:	
 	lb $t1,($s0)
 	beq $t1,$0,_PlayerInfoStr.Line1
 	sb $t1,($s3)
 	addi $s0,$s0,1
 	addi $s3,$s3,1
 	j _PlayerInfoStr.PlayerName
 	
 	# ghi so diem
_PlayerInfoStr.Diem:
 	lb $t1,($s1)
 	beq $t1,$0,_PlayerInfoStr.Line2
	sb $t1,($s3)
	addi $s1,$s1,1
	addi $s3,$s3,1
	j _PlayerInfoStr.Diem
	
	# ghi luot thang
_PlayerInfoStr.WinRound:
	lb $t1,($s2)
 	beq $t1,$0,_PlayerInfoStr.Exit
	sb $t1,($s3)
	addi $s2,$s2,1
	addi $s3,$s3,1
	j _PlayerInfoStr.WinRound

	# ghi '-'
_PlayerInfoStr.Line1:	
	sb $t3,($s3)
	addi $s3,$s3,1
	j _PlayerInfoStr.Diem
_PlayerInfoStr.Line2:	
	sb $t3,($s3)
	addi $s3,$s3,1
	j _PlayerInfoStr.WinRound
		
	# ghi '*'														
_PlayerInfoStr.Exit: 	
 	sb $t2,($s3)
 	
 	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $s2,12($sp)
	lw $s3,16($sp)
 	lw $t0,20($sp)
 	lw $t1,24($sp)
 	lw $t2,28($sp)
 	lw $t3,32($sp)
	addi $sp,$sp,36
	jr $ra
#============== end of _PlayerInfoStr ===============


#============== Thu tuc _RandomNumber ===============
# Tao so ngau nhien
# Truyen vao: khong co
# Tra ve: v0 = random_int
_RandomNumber:
	addi $sp,$sp,-8
	sw $ra,($sp)
    	sw $s0,4($sp) 	# random number
    
    	li $a1, 15 		# Here you set $a1 to the max bound.
    	li $v0, 42  		# generates the random number.
    	syscall
    	
	move $v0,$a0 		# random luu trong $a0 -- chuyen $a0 ve $v0 de tra ve
	
	lw $ra,($sp)
    	lw $s0,4($sp)
	addi $sp,$sp,8
 	jr $ra
#=============== end of _RandomNumber ===============

			
#============= Thu tuc _XuatTrangThai ===============
# Xuat ra trang thai tuong ung voi so luot doan sai
# Truyen vao: a0 = so luot doan sai
# Tra ve: khong
_XuatTrangThai:
	addi $sp, $sp, -16
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	#Load gia tri
	move $s0, $a0

	#Khoi bien i = 1 de so sanh truong hop false = 1
	li $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False1
	#tang i len 2 de so sanh truong hop false = 2
	li $t0, 2
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False2
	#tang i len 3 de so sanh truong hop false = 3
	addi $t0, $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False3
	#tang i len 4 de so sanh truong hop false = 4
	addi $t0, $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False4
	#tang i len 5 de so sanh truong hop false = 5
	addi $t0, $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False5
	#tang i len 6 de so sanh truong hop false = 6
	addi $t0, $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False6
	#tang i len  de so sanh truong hop false = 7
	addi $t0, $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False7
	
	# false = 0
	jal _XuatTrangThai.End1
	
_XuatTrangThai.False1:
	#Sai 1 lan
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall
 	
	jal _XuatTrangThai.End
_XuatTrangThai.False2:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	jal _XuatTrangThai.End
_XuatTrangThai.False3:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	li $v0, 4
	la $a0, tt.tb3
	syscall

	jal _XuatTrangThai.End
_XuatTrangThai.False4:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	li $v0, 4
	la $a0, tt.tb4
	syscall

	jal _XuatTrangThai.End
_XuatTrangThai.False5:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	li $v0, 4
	la $a0, tt.tb5
	syscall

	jal _XuatTrangThai.End
_XuatTrangThai.False6:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	li $v0, 4
	la $a0, tt.tb5
	syscall

	li $v0, 4
	la $a0, tt.tb6
	syscall
	
	jal _XuatTrangThai.End
_XuatTrangThai.False7:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	li $v0, 4
	la $a0, tt.tb5
	syscall

	li $v0, 4
	la $a0, tt.tb7
	syscall

	jal _XuatTrangThai.End
_XuatTrangThai.End:
	li $v0, 4
	la $a0, tt.tb8
	syscall
	li $v0, 4
	syscall
	li $v0, 4
	syscall
	li $v0, 4
	syscall
_XuatTrangThai.End1:
       lw $ra, ($sp)
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	addi $sp, $sp, 16
	jr $ra
#=============== end of _XuatTrangThai ==============


#============= Thu tuc _EnterUsername ===============
# Nhap ten nguoi choi (vao bien player.name)
# Truyen vao: khong
# Tra ve: khong

#Dau thu tuc
_EnterUsername:
	addi $sp,$sp,-56
	sw $ra,($sp)
	sw $s0,4($sp)	
	sw $s1,8($sp)
	sw $s2,12($sp)	
	sw $s3,16($sp)
	sw $s4,20($sp)	
	sw $s5,24($sp)
	sw $s6,28($sp)	
	sw $s7,32($sp)
	sw $t0,36($sp)	
	sw $t1,40($sp)
	sw $t2,44($sp)	
	sw $t3,48($sp)
	sw $t4,52($sp)	
	
#than thu tuc

	#xuat tb1
	li $v0, 4
	la $a0,nhap
	syscall 
	
	#nhap chuoi username
	li $v0,8
	la $a0,str_playername
	la $a1,30
	syscall 
	
	
	li $t4,0			#khoi tao t4=0
	la $s0,str_playername	#Khoi tao chuoi ban dau
	la $s1,player.name		#khoi tao chuoi ket qua
	li $s2,'0'
	li $s3,'9'
	li $s4,'a'
	li $s5,'z'
	li $s6,'A'
	li $s7,'Z'

_EnterUsername.Loop:
	#kiem tra xem so ki tu chuoi co bang 10 khong
	beq $t4,10,_EnterUsername.End_loop
	
	#doc 1 ki tu
	lb $t0,($s0)
	#xem ki tu do co thuoc 0->9 hay khong
	sle $t1,$s2,$t0
	sle $t2,$t0,$s3
	and $t3,$t1,$t2
	
	#neu bang add ki tu vao chuoi ket qua
	bne $t3,0,_EnterUsername.Loop.AddStr
	
	#xem ki tu co thuoc chuoi tu a->z khong
	sle $t1,$s4,$t0
	sle $t2,$t0,$s5
	and $t3,$t1,$t2
	
	#neu bang add ki tu vao chuoi ket qua
	bne $t3,0,_EnterUsername.Loop.AddStr
	
	#xem ki tu co thuoc tu A-> Z khong
	sle $t1,$s6,$t0
	sle $t2,$t0,$s7
	and $t3,$t1,$t2
	
	#neu bang thi add ki tu vao chuoi ket qua
	beq $t3,1,_EnterUsername.Loop.AddStr
	
	#neu ki tu la \n thi ket thuc vong lap
	beq $t0,'\n',_EnterUsername.End_loop
		
	j _EnterUsername.NotPermit

	
_EnterUsername.Loop.AddStr:
	#lay 1 ki tu cua s1 luu vao t0
	sb $t0,($s1)
	
	#tang chuoi $s0
	addi $s0,$s0,1
	
	#tang chuoi $s1
	addi $s1,$s1,1
	
	#tang dem len 1
	addi $t4,$t4,1
	
	j _EnterUsername.Loop
	
_EnterUsername.NotPermit:

	#xuat thong bao chuoi nhap khong hop le
	li $v0,4
	la $a0,nhap.err
	syscall
	#nhap lai tu dau
	j _EnterUsername
	 
_EnterUsername.End_loop:	
	sb $0,($s1)	
#cuoi thu tuc
	#restore thanh ghi
	lw $ra,($sp)
	lw $s0,4($sp)	
	lw $s1,8($sp)
	lw $s2,12($sp)	
	lw $s3,16($sp)
	lw $s4,20($sp)	
	lw $s5,24($sp)
	lw $s6,28($sp)	
	lw $s7,32($sp)
	lw $t0,36($sp)	
	lw $t1,40($sp)
	lw $t2,44($sp)	
	lw $t3,48($sp)
	lw $t4,52($sp)	
	
	#xoa stack
	addi $sp,$sp,56
	
	#quay ve ham main
	jr $ra
#=============== end of _EnterUsername ==============

	
#============ Thu tuc _ReadDataFromFile =============
# Doc file vao chuoi String_in_File
# Truyen vao: khong co
# Tra ve: khong co
_ReadDataFromFile:

	addi $sp,$sp,-8
	sw $ra,($sp)
	sw $s0,4($sp)
	
	# open file
	li $v0,13
	la $a0,file_data_name
	li $a1,0
	li $a2,0
	syscall

	# Luu dia chi file vao $s0
	move $s0,$v0

	# Doc file
	li $v0,14
	move $a0,$s0
	la $a1,String_in_File
	li $a2,500
	syscall		

	lw $ra,($sp)
	lw $s0,4($sp)
	addi $sp,$sp,8
	jr $ra
#============= end of _ReadDataFromFile =============


#========= Thu tuc _GetWordFromPositionI ============
# Lay tu o vi tri i trong chuoi str (luu vao bien SeWo)
# Truyen vao: a0 = $str; a1 = i
# Tra ve: khong

_GetWordFromPositionI:
  
	addi $sp,$sp,-32
	sw $ra,($sp)
	sw $s0,4($sp) #String in File
	sw $s1,8($sp) #Random Number
	sw $s2,12($sp) #result
	sw $t0,16($sp) #bien dem
	sb $t1,20($sp) #character
	sw $t2,24($sp) #compare
   
	#Lay tham so luu vao thanh ghi
	move $s0,$a0 #$s0 ->string in file
	move $s1,$a1 #$s1 ->Random Number
   
	la $s2,SeWo
	
	li $t0,0		#bien dem  
_GetWordFromPositionI.Loop:
	#doc 1 ki tu
	lb $t1,($s0)
     
	beq  $t1,'-',_GetWordFromPositionI.TangDem
	
	#kiem tra xem toi tu thu random_number chua
	sgt  $t2,$t0,$s1
	beq $t2,1,_GetWordFromPositionI.GetWord	
	
	addi $s0,$s0,1
	j _GetWordFromPositionI.Loop

_GetWordFromPositionI.TangDem:
	addi $t0,$t0,1 #Tang dem
	addi $s0,$s0,1
	
	j _GetWordFromPositionI.Loop
	
_GetWordFromPositionI.GetWord:		
	 lb $t1,($s0)
	 beq  $t1,'-',_GetWordFromPositionI.Ketthuc	 
   	 
   	 sb $t1,($s2)
	 addi $s0,$s0,1
	 addi $s2,$s2,1
	 
    	j _GetWordFromPositionI.GetWord  	
_GetWordFromPositionI.Ketthuc:    
 	#gan ki tu ket thuc chuoi cho word
 
 	sb $0,($s2) 
	
	
	
	lw $ra,($sp)
	lw $s0,4($sp) #String in File
    	lw $s1,8($sp) #Random Number
    	lw $s2,12($sp) #Random Number
    	lw $t0,16($sp) #bien dem
   	lb $t1,20($sp) #character
   	lw $t2,24($sp) #compare
	addi $sp,$sp,32
	jr $ra	
#========== end of _GetWordFromPositionI ============	
	
	
	
	
# truyen vo a0 <- $arr, a1 <- $str
# tra ve: khong co
############## Ham _TachChuoi lay Score ######################
_TachChuoilayScore:
	# khai bao kich thuoc stack
	add $sp,$sp,-36
	
	sw $ra,($sp)
	sw $s0,4($sp)		 # arr_number	
	sw $s1,8($sp)		 # str	
	sw $t0,12($sp)		 # character "-"
	sw $t1,16($sp)		 # character "*"
	sw $t2,20 ($sp)		 # the lengh of string of scores
	sw $t3,24 ($sp)         # string of score get from file
	sw $t4 ,28 ($sp)	#number of high score
	sw $t5, 32($sp)
	
	
	move $s0,$a0			# s0 <- $arr
	#la $s0,arr
	move $s1,$a1			# s1 <- $str
	move $t3, $a1			#khoi tao $t3 - not important
	
	#khoi tao
	la $t0,daucach				
	lb $t0,($t0)			# t0 <- "-"
	la $t1,dausao
	lb $t1,($t1)			# t1 <- "*"
	la $t2,0			# length of socre = 0
	la $t4,0			#khoi tao number_of_hight_score = 0
	#-------------lap toi ki tu "-" dau tien--------------------------
TachChuoilayScore.LapToiKiTu:			
	# lay gia tri str[i], i = 0
	lb $a0,($s1)
	# tang $str
	addi $s1,$s1,1
	# str[i] != "-" thi lap
	bne $a0,$t0,TachChuoilayScore.LapToiKiTu
	
	#-----------lap toi ki tu "-" tiep theo de lay diem---------------
TachChuoilayScore.LapLayDiem:		
	# lay gia tri str[i]
	lb $a0,($s1)
	# str[i] != "-" thi lap
	bne $a0,$t0,TachChuoilayScore.LapLayDiem.TangDem
	beq $a0,$t0,TachChuoilayScore.ThoatLap.LayScore	# thoat lap sau khi da doc diem 1 nguoi choi
TachChuoilayScore.ThoatLap.LayScore:
	#khi lay duoc 1 score thi gan ki tu ket thuc chuoi
	sb $0,($t3) 
	#tru di $t3
	sub $t3,$t3,$t2
	la $t2,0 # length of socre = 0
	
	#debug
	#move $a0,$t3
	#li $v0,4 #4 is print string
	#syscall
	#goi ham String_to_Int de doi qua int roi luu vao arr
	
	#truyen tham so
	la $a0,($t3)
	
	#debug
	#goi ham String_to_int
	jal _StringToInt
	#lay gia tri tra ve
	sw $v0,($s0)
	addi $s0,$s0,4
	#debug
	#lw $a0,($s0)
	#li $v0,1
	#syscall
	
	
	
	#debug
	#move $a0,$s0
	#li $v0,1
	#syscall	
	
	#(tang dem $s0)
	
	addi $t4,$t4,1 #tang number of high score len 1
	j TachChuoilayScore.ThoatLap.Lap		
TachChuoilayScore.LapLayDiem.TangDem:							
	# in ra man hinh =>> DOI THANH INT => PUSH VAO ARR
	sb $a0,($t3) # load ki tu cua score vao $t3
	
	addi $t3,$t3,1 # tang dia chi $t3
	addi $t2,$t2,1 # tang length of score +=1

	
	#debug
	#li $v0,11
	#syscall
	
	# tang $str
	addi $s1,$s1,1												
	j TachChuoilayScore.LapLayDiem	
	
	#-------------------lap toi ki tu "*"-------------------------		 	
TachChuoilayScore.ThoatLap.Lap:	
	addi $s1,$s1,1
	lb $a0,($s1)
	bne $a0,$t1,TachChuoilayScore.ThoatLap.Lap	# chua gap "*" thi lap

	# kiem tra "*" la ki tu cuoi cung
	addi $s1,$s1,1
	lb $a0,($s1)
	beqz $a0,TachChuoilayScore.Thoat		# end of string thi thoat
	j TachChuoilayScore.LapToiKiTu	# quay lai tu dau lay diem nguoi choi tiep theo
	
TachChuoilayScore.Thoat:	  
	move $v0,$t4
	
	# restore thanh ghi
	lw $ra,($sp)
	lw $s0,4($sp)			
	lw $s1,8($sp)			
	lw $t0,12($sp)		
	lw $t1,16($sp)	
	sw $t2,20 ($sp)		 # the lengh of string of scores
	sw $t3,24 ($sp)         # string of score get from file
	sw $t4 ,28 ($sp)	#number of high score
	sw $t5, 32($sp)
	# xoa stack
	add $sp,$sp,36
	# quay ve 
  	jr $ra
####################################

# truyen vo $a0 <- $str
# tra ve $v0 = gia tri str
################## Ham _StringToInt #################################	
_StringToInt:	
	addi $sp,$sp,-32
	sw $ra,($sp)
	sw $t0,4($sp)
	sw $s0,8($sp)
	sw $t1,12($sp)
	sw $t2,16($sp)
	sw $t3,20($sp)
	sw $t4,24($sp)
	sw $s1,28($sp)
	
	move $s0,$a0 			# s0 <- &str
	
	#------------dem chuoi vua nhap co n ky tu-------------------
	# khoi tao
	li $t0,0 			# n = 0
SoKiTu.Lap:
	# doc 1 ki tu
	lb $a0,($s0)
	# kiem tra neu != 0 thi tang dem
	bnez $a0,SoKiTu.TangDem
	j SoKiTu.Thoat 
SoKiTu.TangDem:
	addi $t0,$t0,1 		# n ++	
	addi $s0,$s0,1 		# tang dia chi
	j SoKiTu.Lap
SoKiTu.Thoat:
	addi $s0,$s0,-1 		# giam s0 (vi [s0] dang la 0)

	#----------------------tinh ket qua-----------------------------
	
	#khoi tao
	li $t1,1			# i = 1
	li $t2,10			# 10
	li $t3,0			# dem = 0
	li $s1,0			# kq = 0
Value.Lap:
	slt $t4,$t3,$t0		# dem < n
	bne $t4,$0,Value.TangDem	
	beq $t4,$0,Value.Thoat	
	
Value.TangDem:
	# doc 1 ki tu ($s0 dang o vi tri cuoi cung)
	move $a0,$s0
	# lay gia tri ki tu (dung ham SimpleNum)
	jal _SimpleNum
	# lay kq tra ve
	move $a0,$v0
	
	mult $a0,$t1			# [str] * i
	mflo $a0
	add $s1,$s1,$a0		# kq += [str] * i
	# tang dem
	mult $t1,$t2			# i * 10
	mflo $t1
	addi $t3,$t3,1		# dem ++
	addi $s0,$s0,-1 		# giam dia chi
	j Value.Lap
			
Value.Thoat:						
	move $v0,$s1
	
	#debug
	#la $a0,($v0)								
	#li $v0,1 #4 is print string
	#syscall	
	
	lw $ra,($sp)
	lw $t0,4($sp)
	lw $s0,8($sp)
	lw $t1,12($sp)
	lw $t2,16($sp)
	lw $t3,20($sp)
	lw $t4,24($sp)
	lw $s1,28($sp)
	addi $sp,$sp,32
	jr $ra
########################################
	
								
# truyen vao a0 <- $str (0-9)
# tra ve $v0 = gia tri str	
################## Ham _SimpleNum ############################
_SimpleNum:
	addi $sp,$sp,-8
	sw $ra, ($sp)
	sw $s0,4($sp)
	
	lb $s0,($a0)
	
	beq $s0,48,Zero
	beq $s0,49,One
	beq $s0,50,Two
	beq $s0,51,Three
	beq $s0,52,Four
	beq $s0,53,Five
	beq $s0,54,Six
	beq $s0,55,Seven
	beq $s0,56,Eight
	beq $s0,57,Nine
Zero:
	li $v0,0
	j Exit
One:
	li $v0,1
	j Exit
Two:
	li $v0,2
	j Exit
Three:
	li $v0,3
	j Exit
Four:
	li $v0,4
	j Exit
Five:
	li $v0,5
	j Exit
Six:
	li $v0,6
	j Exit
Seven:
	li $v0,7
	j Exit
Eight:
	li $v0,8
	j Exit
Nine:
	li $v0,9
	j Exit
Exit:	
	lw $ra, ($sp)
	lw $s0,4($sp)
	addi $sp,$sp,8
	jr $ra
######################################
#=============== Xuat mang Int=================#
_XuatMangInt:
	addi $sp,$sp,-32
	sw $ra,($sp)
	sw $s0,4($sp) #n
	sw $s1,8($sp) #arr
	sw $t0,12($sp)
	sw $t1,16($sp)	
		
	#Lay tham so luu vao thanh ghi
	move $s0,$a0
	move $s1,$a1
#THan thu tuc
	#Khoi tao vong lap
	li $t0,0 #i=0
_XuatMangInt.Lap:
	#xuat arr[i]
	lw $a0,($s1)
	li $v0,1
	syscall
	
	#xuat khoang trang
	li $v0,11
	li $a0,' '
	syscall
	
	#tang dia chi mang
	addi $s1,$s1,4
	addi $t0,$t0,1
	
	#kiem tra i<n thi lap
	slt $t1,$t0,$s0
	beq $t1,1,_XuatMangInt.Lap

	#Cuoi thu tuc
		#restore
		lw $ra,($sp)
		lw $s0,4($sp) #n
		lw $s1,8($sp) #arr
		lw $t0,12($sp)
		lw $t1,16($sp)	
		
		#xoa stack
		addi $sp,$sp,32
		
		#tra ve 
		jr $ra
#=============== Xuat mang Int =================#  
#=============== Buble Sort ==============#
_Sort:
    addi $sp,$sp,-44
    sw $ra,($sp)
    sw $s0,4($sp) #n
    sw $s1,8($sp) #arr_score_i
    sw $s2,12($sp) #arr_score_j
    sw $s3,16($sp) #arr_player_tenp
    sw $s4,20($sp) #arr_player_tenp
    sw $t0,24($sp) #i
    sw $t1,28($sp)  #j
    sw $t3,32($sp)  #compare
    sw $t4,36($sp)  #Arr[i]
    sw $t5,40($sp)  #Arr[j]
    sw $t6,44($sp)  #gia tri bang 4
    #Lay tham so luu vao thanh ghi
    move $s0,$a0
    #load arr_score and arr_player
    la $a0,arr_player
    move $s1,$a1 #s1 arr_score
    move $s3,$a0 #s1 arr_score
#THan thu tuc
    #Khoi tao vong lap
    li $t0,0 #i=0
    li $t1,0 #j=0
_Sort.Lap_i:

    #xuat a[i]
    li $t1,0 #j=0   
    move $s2,$a1
    move $s4,$a0
    _Sort.Lap_j:
        #kiem tra de swap 
        lw $t4,($s1) #lay arr[i]
        lw $t5,($s2) #lay arr[j]
        slt $t3, $t4, $t5
        beq $t3,1,_Sort.continue
       
        #swap _ score
        sw  $t5, ($s1)  #gan a[i] bang a[j]
        li $t6,4 	#gan t6 = 4
        
        mult $t6,$t0   #lay 4*$t0(i*4)
        mflo $t3	#gan vao $t3
        
        sub $s1,$s1,$t3 #lui a[i] di $t3 vi tri
        
        mult $t6,$t1	#lay 4*$t0(j*4)
        mflo $t3	#gan vao $t3
        
        add $s1,$s1,$t3	#tien toi a[j] bang cach them a[0] j*4 vi tri
        sw  $t4, ($s1) #gan a[j] = a[i]
        
        sub $s1,$s1,$t3#tra lai ve a[0]
        
        mult $t6,$t0#i*4
        mflo $t3	#luu vao $t3
        
        add $s1,$s1,$t3#tra lai ve a[i]
        
        lw $t4,($s3) #lay arr[i]
        lw $t5,($s4) #lay arr[j]
         #swap _ player
        sw  $t5, ($s3)  #gan a[i] bang a[j]
        li $t6,4 	#gan t6 = 4
        
        mult $t6,$t0   #lay 4*$t0(i*4)
        mflo $t3	#gan vao $t3
        
        sub $s3,$s3,$t3 #lui a[i] di $t3 vi tri
        
        mult $t6,$t1	#lay 4*$t0(j*4)
        mflo $t3	#gan vao $t3
        
        add $s3,$s3,$t3	#tien toi a[j] bang cach them a[0] j*4 vi tri
        sw  $t4, ($s3) #gan a[j] = a[i]
        
        sub $s3,$s3,$t3#tra lai ve a[0]
        
        mult $t6,$t0#i*4
        mflo $t3	#luu vao $t3
        
        add $s3,$s3,$t3#tra lai ve a[i]
         
         
        _Sort.continue:
        #tang dia chi mang
        addi $s2,$s2,4  #arr_score[j++]
        addi $s4,$s4,4  #arr_player[j++]
        addi $t1,$t1,1 #tang j++
        
        #kiem tra i<n thi lap
        slt $t2,$t1,$s0
        beq $t2,1,_Sort.Lap_j
    
        
    #tang dia chi mang
    addi $s1,$s1,4  #arr_score[i++]
    addi $s3,$s3,4  #arr_player[i++]
    addi $t0,$t0,1 #tang i++
    #kiem tra i<n thi lap
    slt $t1,$t0,$s0
    beq $t1,1,_Sort.Lap_i
    
    #Cuoi thu tuc
        #restore
	lw $ra,($sp)
    	lw $s0,4($sp) #n
    	lw $s1,8($sp) #arr_score_i
    	lw $s2,12($sp) #arr_score_j
    	lw $s3,16($sp) #arr_player_tenp
    	lw $s4,20($sp) #arr_player_tenp
   	lw $t0,24($sp) #i
   	lw $t1,28($sp)  #j
   	lw $t3,32($sp)  #compare
    	lw $t4,36($sp)  #Arr[i]
    	lw $t5,40($sp)  #Arr[j]
    	lw $t6,44($sp)  #gia tri bang 4
        
        #xoa stack
        addi $sp,$sp,44
        
        #tra ve 
        jr $ra
#=============== Buble Sort ==============#
############## Ham _TachChuoi lay Player ######################
_TachChuoilayPlayer:
	# khai bao kich thuoc stack
	add $sp,$sp,-28
	
	sw $ra,($sp)
	sw $s0,4($sp)		 # arr_player	
	sw $s1,8($sp)		 # str	
	sw $t0,12($sp)		 # character "-"
	sw $t1,16($sp)		 # character "*"
	sw $t2,20 ($sp)		 # the lengh of string of player
	sw $t3,24 ($sp)         # string of score get from file
	move $s0,$a0			# s0 <- $arr_player
	move $s1,$a1			# s1 <- $str
	la $t3,str_player			#khoi tao $t3 - not important
	
	#khoi tao
	la $t0,daucach				
	lb $t0,($t0)			# t0 <- "-"
	la $t1,dausao
	lb $t1,($t1)			# t1 <- "*"
	la $t2,0			# length of socre = 0
	la $t4,0			# length of socre = 0
	#-------------doc ten dau tien --------------------------
TachChuoilayPlayer.GetPlayer_1st:			
	
	lbu $a0,($s1)
	
	beq $a0,$t0,TachChuoilayPlayer.StorePlayertoArr
	#ghi player 1st
	sb $a0,($t3)
	addi $t3,$t3,1 # increase pointer
	addi $t2,$t2,1 # length of str_player +=1
	addi $s1,$s1,1
	#
	j TachChuoilayPlayer.GetPlayer_1st 	
TachChuoilayPlayer.Lap:
	lb $a0,($s1)
	beq $a0,$t1,TachChuoilayPlayer.GetPlayer
	addi $s1,$s1,1
	j TachChuoilayPlayer.Lap
	
TachChuoilayPlayer.GetPlayer:	
	addi $s1,$s1,1
	lbu $a0,($s1)
	beqz $a0,TachChuoilayPlayer.Thoat
	beq $a0,$t0,TachChuoilayPlayer.StorePlayertoArr
	#lay player luu vao $t3
	sb $a0,($t3)
	addi $t3,$t3,1
	addi $t2,$t2,1 # length of str_player +=1
	j TachChuoilayPlayer.GetPlayer
TachChuoilayPlayer.StorePlayertoArr:
	sb $0,($t3)
	sub  $t3,$t3,$t2 #tra con tro ve ban dau
	#luu $t3 vao arr_player
	sw $t3,($s0)
	addi $t2,$t2,1
	add $t3,$t3,$t2
	add $t2,$0,$0 # length of str_player = 0
	addi $s0,$s0,4
	j TachChuoilayPlayer.Lap
TachChuoilayPlayer.Thoat:	  
	
	# restore thanh ghi
	lw $ra,($sp)
	lw $s0,4($sp)		 # arr_player	
	lw $s1,8($sp)		 # str	
	lw $t0,12($sp)		 # character "-"
	lw $t1,16($sp)		 # character "*"
	lw $t2,20 ($sp)		 # the lengh of string of scores
	lw $t3,24 ($sp)         # string of score get from file
	# xoa stack
	add $sp,$sp,28
	# quay ve 
  	jr $ra
####################################
# truyen vo $a0 <- $player_arr
# tra ve 
#=============== Xuat mang Player =================#
_XuatMangPlayer:
	addi $sp,$sp,-20
	sw $ra,($sp)
	sw $s0,4($sp) #n
	sw $s1,8($sp) #arr
	sw $t0,12($sp)
	sw $t1,16($sp)	
	
	#Lay tham so luu vao thanh ghi
	move $s0,$a0 #n
	move $s1,$a1 #arr_player
	
	
#THan thu tuc
	#Khoi tao vong lap
	li $t0,0 #i=0
	
_XuatMangPlayer.Lap:
	#xuat arr[i]
	lw $a0,($s1)
	li $v0, 4 #4 is print string
	syscall
	#xuat khoang trang
	li $v0, 11
	li $a0,' '
	syscall
	
	#tang dia chi mang
	addi $s1,$s1,4
	addi $t0,$t0,1
	#kiem tra i<n thi lap
	slt $t1,$t0,$s0
	beq $t1,1,_XuatMangPlayer.Lap

	#Cuoi thu tuc
	#restore
	lw $ra,($sp)
	lw $s0,4($sp) #n
	lw $s1,8($sp) #arr
	lw $t0,12($sp)
	lw $t1,16($sp)	
		
	#xoa stack
	addi $sp,$sp,20
		
	#tra ve 
	jr $ra
#=============== Xuat mang Player =================#  
#=============== Xuat Top 10 Player and score =================#
_XuatTop10:
	addi $sp,$sp,-20
	sw $ra,($sp)
	sw $s0,4($sp) #n
	sw $s1,8($sp) #arr_player
	sw $s2,12($sp) #arr_score
	sw $t0,16($sp)
	sw $t1,20($sp)	
	
	
	#Lay tham so luu vao thanh ghi
	move $s0,$a0 #n
	la $s1,arr_player
	la $s2,arr_score
	
	
	
#THan thu tuc
	#Khoi tao vong lap
	li $t0,0 #$t0 = 0
	li $t1,10
blt  $s0,10,_XuatTop10.Lap	
#kiem tra xem #n co lon hon 10 khong
bgt  $s0,10,_XuatTop10.setNto10
_XuatTop10.setNto10:
	add $s0,$zero,10
	j _XuatTop10.Lap
	
_XuatTop10.Lap:
	#xuat ki tu xuong don
	li $v0, 11
	li $a0,'\n'
	syscall
	#xuat arr[i]
	lw $a0,($s1)
	li $v0, 4 #4 is print string
	syscall
	#xuat khoang trang
	li $v0, 11
	li $a0,' '
	syscall
	
	lw $a0,($s2)
	li $v0, 1 #4 is print string
	syscall
	
	
	#tang dia chi mang
	addi $s1,$s1,4
	addi $s2,$s2,4
	addi $t0,$t0,1
	#kiem tra i<n thi lap
	slt $t1,$t0,$s0
	beq $t1,1,_XuatTop10.Lap

	#Cuoi thu tuc
	#restore
	lw $ra,($sp)
	lw $s0,4($sp) #n
	lw $s1,8($sp) #arr
	lw $t0,12($sp)
	lw $t1,16($sp)	
		
	#xoa stack
	addi $sp,$sp,20
		
	#tra ve 
	jr $ra
#=============== Xuat mang Player =================#  
	
	
	
	
	
	
	
