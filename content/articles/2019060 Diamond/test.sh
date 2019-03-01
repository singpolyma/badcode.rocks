#!/bin/sh

if [ $# -ne 1 ]; then
		echo "Usage: sh test.sh /path/to/program" 1>&2
		exit 1
fi

PROGRAM="$1"

assert_run() {
	EXPECTED_EXIT="0"
	EXPECTED_OUTPUT="$1"
	shift
	OUTPUT="$("$PROGRAM" "$@")"
	EXIT="$?"
	if [ "$EXPECTED_EXIT" -ne "$EXIT" ]; then
		echo "$PROGRAM $@" 1>&2
		echo "expected exit: $EXPECTED_EXIT" 1>&2
		echo "got: $EXIT" 1>&2
		exit 1
	fi

	if [ "$EXPECTED_EXIT" -eq 0 -a "$EXPECTED_OUTPUT" != "$OUTPUT" ]; then
		echo "$PROGRAM $@" 1>&2
		echo "expected: $EXPECTED_OUTPUT" 1>&2
		echo "got: $OUTPUT" 1>&2
		exit 1
	fi
}

assert_run "A" A

assert_run " A 
B B
 A " B

assert_run "  A  
 B B 
C   C
 B B 
  A  " C

assert_run "   A   
  B B  
 C   C 
D     D
 C   C 
  B B  
   A   " D

assert_run "                                     A                         
                                    B B                        
                                   C   C                       
                                  D     D                      
                                 E       E                     
                                F         F                    
                               G           G                   
                              H             H                  
                             I               I                 
                            J                 J                
                           K                   K               
                          L                     L              
                         M                       M             
                        N                         N            
                       O                           O           
                      P                             P          
                     Q                               Q         
                    R                                 R        
                   S                                   S       
                  T                                     T      
                 U                                       U     
                V                                         V    
               W                                           W   
              X                                             X  
             Y                                               Y 
            Z                                                 Z
             Y                                               Y 
              X                                             X  
               W                                           W   
                V                                         V    
                 U                                       U     
                  T                                     T      
                   S                                   S       
                    R                                 R        
                     Q                               Q         
                      P                             P          
                       O                           O           
                        N                         N            
                         M                       M             
                          L                     L              
                           K                   K               
                            J                 J                
                             I               I                 
                              H             H                  
                               G           G                   
                                F         F                    
                                 E       E                     
                                  D     D                      
                                   C   C                       
                                    B B                        
                                     A                         " Z
