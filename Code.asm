                        
name "strig-search-program"  

; add your code here
.model small
  db 30,?, 30 dup(' ')
name db $,<' '> 


.data
    string db 60 dup(?)      ;60 place empty array    
    subString db 60 dup(?)   ;sub string to search for
    outt db 0ah,0dh,         "entre a sentence or press entre 3 times to terminate:$"    
    subStr db 0ah,0dh,       "entre keyword or press entre 3 times to terminats:$" 
    trial_cnt db  0          ;number of trial allowed for user 
    error db 0ah,0dh,        "error: max sentance length 30 char, max word length 10 char..try agian.",0ah,0dh,"$"    
    lenCount  dw  0  
    steps dw 0      
    final db 0ah,0dh,        "Count value = $"
    onsMatchCounter db 0
    tensMatchCounter db 0   
    
    
.code   
    
    main proc
        mov ax,@data
        mov ds,ax 
        
    start_String:    
        lea dx,outt
        mov ah,09H
        int 21H
        mov si,offset string
        mov lenCount, 0h ;counter to count number of char taken from user we must load it with zero everytime we try to get new input 
    input_String:
        ;take input from user
        mov ah,1H
        int 21H  
      
        ;if user press entre check if he has more trial or he pressed entre 3 times, go to check_trail for that
        cmp al,13
        je check_trial
        
        ;if the input is not enter char we need to increase word length counter
        ;check if we excedded the allowed word length  
        ;if so jump to error state 
        inc lenCount
        cmp lenCount,31
        je  error_sentence 
        
          
        ;move input char to memory
        mov [si],al
        inc si
        jmp input_String
                 
                 
    error_sentence:
        ;display error message
        lea dx,error
        mov ah,09H
        int 21H   
        
        ;repeat
        jmp start_String
        
               
    check_trial:
        
        ;if the user input any chars befor pressing entre then we captured the string and 
        ;now we go to capture the substring to search for in the string
        ;remeber to terminate the current string with $ for end of string indication
        cmp si,offset string 
        jne start_subString
        
        ;if the user didn't input any char check for the number of trials left
        ;if the user press entre three times end the program
        ;else try again with the user
        
        
        ;print new line and set cruser at the start of the line
        mov dl,13
        mov ah,2
        int 21H  
        mov dl,10
        mov ah,2
        int 21h
        
        ;user allowed three entres to terminate the program
        ;here we check for each entre char if the upper limit reached
        ;and terminate the program if so
        inc trial_cnt
        cmp trial_cnt, 3
        je last
        jmp start_String
                   
                   
    start_subString:  
    
        ;befor doing anything we need to terminate the previous string with the end
        ;of string char
        mov [si],'$'
        
        ;now we need to give the user three more trials for the sub string
        ;so we zero the variable trial_cnt
        mov trial_cnt,0
        
        ;display the interactive text for the second string
        lea dx,subStr
        mov ah,09H
        int 21H
        
        ;move address of the subsring variable to internal register to keep track of it
        ;and manage to store char taken from user
        mov si,offset subString                  
        
        ;zero lencouter variable to take length of the new string
        mov lenCount, 0h
        
        
    input_subString:
        ;take input from user
        mov ah,1H
        int 21H  
        
        ;check for enter char and go to check in trial routine
        cmp al,13
        je check_trial_subStr
        
        
        ;if the input is not enter char we need to increase word length counter
        ;check if we excedded the allowed word length  
        ;if so jump to error state 
        inc lenCount
        cmp lenCount,11
        je  error_word 
        
        ;move input char to memory
        mov [si],al
        inc si
        jmp input_subString
   
    error_word:
        ;display error message
        lea dx,error
        mov ah,09H
        int 21H   
        
        ;repeat
        jmp start_subString
  
  
          
    check_trial_subStr:
        
        ;if the user input any chars befor pressing entre then we captured the string and 
        ;now we go to capture the substring to search for in the string
        ;remeber to terminate the current string with $ for end of string indication
        cmp si,offset subString 
        jne count_match_string
   
        ;print new line and set curser at the start of the line
        mov dl,13
        mov ah,2
        int 21H  
        mov dl,10
        mov ah,2
        int 21h
        
        ;user allowed three entres to terminate the program
        ;here we check for each entre char if the upper limit reached
        ;and terminate the program if so
        inc trial_cnt
        cmp trial_cnt, 3
        je last
        jmp start_subString
   
    count_match_string:     
        ;put end char at the end of input string and load address to DI register
        mov [si],'$'
        
        ;load string offset to match
        mov si,offset string
        mov di,offset subString     
        mov al,[si]
        mov dl,[bx]
        cmp dl,al
        je match_string
        jmp print 
        
        
    match_string:
        
        ;load loop count to loop register
        mov cx,lenCount
        ;load string offset to bl register
        mov bx,si
        l1:
           mov al,[bx]  
           mov dl,[di]
           cmp dl,al  
           jne next
           
           ;end of string to search for
           cmp [bx],'$'
           je print 
           
           
           inc di
           inc bx
           
        loop l1 
        ;if the loop ended then we found a match
        ;increment match_found_counter 
        ;incremet string indx to point to the next char then  then jmp to count_match_string
        inc onsMatchCounter 
        
        cmp onsMatchCounter,10
        jne next
        
        ;if equal 
        
        inc tensMatchCounter
        mov onsMatchCounter,0
        
        jmp next
        
    next:
          inc  si
          cmp [si],'$'
          je  print
          mov di,offset string
          mov al,[si]
          cmp [di],al
          je match_string
          jmp next
   
    print:   
       mov di,offset final  
       
    put_char:
       mov dl, [di]
       mov ah, 5       ; MS-DOS print function.
       int 21h
       inc di	        ; next char.  
       
       cmp [di],'$'
       jne put_char
       
       
       
       ;print the value distributed on two variables 
       add tensMatchCounter,48
       mov dl,tensMatchCounter
       mov ah,5
       int 21h 
           
       
       add onsMatchCounter,48
       mov dl,onsMatchCounter
       mov ah,5
       int 21h
       


       jmp last
          
            
    last:   
        mov ax, 0       ; wait for any key...
        int 16h
        
        ;clear page if user input anykey
        mov dl, 12      ; form feed code. page out!
        mov ah, 5
        int 21h 
        
        
        ;halt system
        mov ah,4ch
        int 21h
        
        
        
        
        
        
end
ret