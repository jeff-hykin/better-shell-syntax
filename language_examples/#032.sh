#!/bin/bash
function run_args() {
	args=("date" "--utc")
	
    # double quoted command
    "${args[@]}" echo hi
	echo 'use "quota" here'
    
    # double quoted command with prefix
    imma_prefix"${args[@]}" echo hi
	echo 'use "quota" here'
    
    # double quoted command with postfix
    "${args[@]}"imma_postfix echo hi
	echo 'use "quota" here'
    
    # double quoted command with postfix and prefix
    imma_prefix"${args[@]}"imma_postfix echo hi
	echo 'use "quota" here'
    
    # single quoted multiline command with postfix and prefix and prefix operator
    ! imma_prefix"${args[@]} echo hi
	echo "imma_postfix argument1
    
    # double quoted command and prefix operator
    ! "${args[@]}" echo hi
	echo 'use "quota" here'
    
    # double quoted command with prefix and prefix operator
    ! imma_prefix"${args[@]}" echo hi
	echo 'use "quota" here'
    
    # double quoted command with postfix and prefix operator
    ! "${args[@]}"imma_postfix echo hi
	echo 'use "quota" here'
    
    # double quoted command with postfix and prefix and prefix operator
    ! imma_prefix"${args[@]}"imma_postfix echo hi
	echo 'use "quota" here'
    
    # single quoted command
    '${args[@]}' echo hi
	echo 'use "quota" here'
    
    # single quoted command with prefix
    imma_prefix'${args[@]}' echo hi
	echo 'use "quota" here'
    
    # single quoted command with postfix
    '${args[@]}'imma_postfix echo hi
	echo 'use "quota" here'
    
    # single quoted command with postfix and prefix
    imma_prefix'${args[@]}'imma_postfix echo hi
	echo 'use "quota" here'
    
    # single quoted command and prefix operator
    ! '${args[@]}' echo hi
	echo 'use "quota" here'
    
    # single quoted command with prefix and prefix operator
    ! imma_prefix'${args[@]}' echo hi
	echo 'use "quota" here'
    
    # single quoted command with postfix and prefix operator
    ! '${args[@]}'imma_postfix echo hi
	echo 'use "quota" here'
    
    # single quoted command with postfix and prefix and prefix operator
    ! imma_prefix'${args[@]}'imma_postfix echo hi
	echo 'use "quota" here'
    
    # single quoted multiline command with postfix and prefix and prefix operator
    ! imma_prefix'${args[@]} echo hi
	echo 'imma_postfix argument1
    
    
}
run_args