/*

 */

#define _DEFAULT_SOURCE 1  /* don't worry about this - simply needed for IO stuff */

#include <stdio.h>
#include <termios.h>
#include <stdlib.h>
#include <time.h>

#define CR 13
#define LF 10

#define bool int
#define true 1
#define false 0

#define MAX_ROMANS 7
#define MAX_STRING 20
#define S_(x) #x
#define S(x) S_(x)
#define NO_ERROR 0
#define MAX_DIGIT_COUNT 3
#define C_NULL '\0'
#define QUIT 'Q'

typedef struct {
    char digit;
    int arab_value;
    int subtractor_index;
    int count;
    bool modified;
    bool modifier;
    int max_times;
} ROMAN_DIGIT;

ROMAN_DIGIT all_roman [MAX_ROMANS] = {{'I', 1,   -1, 0, false, false, MAX_DIGIT_COUNT},
				      {'V', 5,    0, 0, false, false, 1},
				      {'X', 10,   0, 0, false, false, MAX_DIGIT_COUNT},
				      {'L', 50,   2, 0, false, false, 1},
				      {'C', 100,  2, 0, false, false, MAX_DIGIT_COUNT},
				      {'D', 500,  4, 0, false, false, 1},
				      {'M', 1000, 4, 0, false, false, MAX_DIGIT_COUNT}
};
    
int main()
{
    char string[MAX_STRING+1]; /*  +1 is for the NULL ternminator */
    char format_string[] = "%" S(MAX_STRING) "s";
    int sum,
	s_index,
	r_last,
	r_index,
	i;
    int error;

    printf("\nThis program converts numbers in Improved Roman notation to Arabic notation.\n");
    printf("\tInput is limited to UPPER case Roman digits only.\n");
    printf("\tTo exit the program type only the Enter key.\n\n");

    printf("Input a Roman number (Press 'Q' to exit): ");

    scanf(format_string, string);
    
    while(string[0] != QUIT) { /*C_NULL) {*/
	sum = 0;
	s_index = 0;
	r_last = MAX_ROMANS - 1;
	error = NO_ERROR;
	while ((string[s_index] != C_NULL) && error == NO_ERROR)
	{
	    r_index = MAX_ROMANS - 1;
	    while (r_index >= 0 && string[s_index] != all_roman[r_index].digit)
		r_index--;

	    if (r_index < 0)
	    {
		error = 1;            /* invalid roman digit */
	    }
	    else
	    {
		if (r_index > r_last)
		{
		    if (all_roman[r_index].subtractor_index != r_last
                      || all_roman[r_last].count > 1)
			error = 2;         /* digits out of order, i.e. IM */
		    else
		    {
			sum = sum + all_roman[r_index].arab_value - 2 
			    * all_roman[r_last].arab_value;
			(all_roman[all_roman[r_index].subtractor_index].count)--;
			all_roman[r_index].count++;
			all_roman[r_index].modified = true;
			all_roman[all_roman[r_index].subtractor_index].modifier = true;
		    }
		}
		else
		{
		    if (all_roman[r_index].modifier)
		    {
			error = 3;    /* digit already used as modifier, i.e. CMC */
		    }
		    else
		    {
			if (all_roman[r_index].subtractor_index 
			    == all_roman[r_index+1].subtractor_index 
			    && all_roman[all_roman[r_index].subtractor_index].modifier)
			{
			    error = 4;  /* illegal combination, i.e. XCL */
			}
			else
			{
			    all_roman[r_index].count++;
			    if (all_roman[r_index].count <= all_roman[r_index].max_times)
			    {
				sum = sum + all_roman[r_index].arab_value;
				r_last = r_index;
			    }
			    else
				error = 5;  /* exceeding max times this digit can occur */
			}
		    }
		}
	    }
	    if (error == NO_ERROR)
	    {
		s_index++;
		r_last = r_index;
	    }
	}

	if (error)
	{
	    printf("Character at position %d(%c)\n", s_index, string[s_index]);
	    switch(error)
	    {
	    case 1:
		printf("\tis not a valid Roman digit\n");
		break;
	    case 2:
		printf("\tis out of order for a Improved Roman number\n");
		break;
	    case 3:
		printf("\thas been used as a modifier and can't be used unmodified\n");
		break;
	    case 4:
		printf("\tcombination of the modified prior digit and this digit is\n");
		printf("\tan invalid Roman number\n");
		break;
	    case 5:
		printf("\thas exceeded the maximum occurrences for this digit\n");
		break;
	    default:
		printf("In error handling with an invalid error code\n");
	    }
	}
	else
	    printf("%d\n", sum);

	for (i = 0; i < MAX_ROMANS; i++)
	{
	    all_roman[i].count = 0;
	    all_roman[i].modified = false;
	    all_roman[i].modifier = false;
	}
	printf("\nInput a Roman number (Press 'Q' to exit): ");
	scanf(format_string, string);
   }

    return 0;
}
