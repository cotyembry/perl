!#/Users/johembry/perl

#Author:	John Coty Embry
#Date:		02/04/2016
#Program Comment:	This program will take an export of all of the CSP files in XML format (from the export), iterate through each CSP file individually, and allow you to add or change anything within each file. Additionally, you can exclude specific, individual files within the XML export (refer to if statement, and code comments below for usage example on how to account for that)

#Usage Example: 
#from the command line write:	perl cspScript.pl > yourNewFileName.txt 
#Note: the > redirects output from this script to a new file of your choosing
#	make sure to open the correct file that this Script refers to so that it can get the CSP files (see open FH etc below which are the file handles)


#here just change the file you want to open and go through that contains all of the CSP files (change all of the next 3 lines to the same file name)
open FH, "./cspData.xml";
open AFH, "./cspData.xml";
open BFH, "./cspData.xml";

@filesToUpdate;
@startOfFileLines;
@endOfFileLines;

$lineNumber = 1;
while(<FH>) {
	
	
	#go through and get all of the lines the CSP files are declared on from the master .csp files
	if($_ =~ m/(\<CSP[ ]+name.*\>)/g) {
		$fileName = $1; #the $1 will recognize the first match within the () 
		$fileName =~ s/ //g; #this removes spaces for more consistent comparing

		$fileName =~ m/(\"[a-zA-Z0-9\.]+\")/g; #this gets the first quote value
		$fileName = $1;
		$length = length $fileName;

		$length = $length - 2;
		$fileName = substr $fileName, 1, $length; #this strips away the quotes
		#now $fileName can format to output all of the files that are in the .xml file
		#so lets push them onto the array, along with the line number it's found on
		@fileName_lineNumber = ($fileName, $lineNumber);
		push(@filesToUpdate, "$fileName");
		push(@startOfFileLines, "$lineNumber");

		
	}

	
	$lineNumber++;
}


close FH;

#get the length of the array
#I don't think I need this anymore...
$lengthOfFilesToUpdate = 0;
while(exists $filesToUpdate[$i]) {
	$lengthOfFilesToUpdate++;
	$i++;
}
$lengthOfFilesToUpdate = $lengthOfFilesToUpdate/2; #since the array is double long due to the format of it

#okay, now that I have all of the fileNames in the array, lets start updating the files

$i = 0;
$j = 1;
$inc = 0;
$endOfCSPFileHelper = 0; #I'll use this to know exactly the line where the end of file is for the current CSP file in the array

$startOfCSPFile = 0; #reset my line checker variable
$justSet = 0;

#this gets the line number for each CSP file
while(<AFH>) {
	$endOfCSPFileHelper++;
	if($_ =~ m/<\/CSP\>/g) {
		push(@endOfFileLines, "$endOfCSPFileHelper");
	}
}



#let's get all of the individual CSP files out of the page
$i = 0;
$currentLineNumber = $startOfFileLines[0];
$lineIsCurrent = 0;

$inc = 1; #this can be used later to reference the actual line number in the file

#get the CSP file text for the distinct file in the array
while($i <= scalar @filesToUpdate) {


	$currentLineNumber = $startOfFileLines[$i];
	#print"current $currentLineNumber\n";
	#print"end $endOfFileLines[$i]\n";

	$inc = 0;
	$printedOnce = 0;
	while(<BFH>) {
		#these get reset each iteration through the while loop so I can use it later and not worry that it isn't the right value
		$matchedDoctypeAllOnTheSameLine = 0; 
		$matchedDoctypeEndingOnDifferentLines = 0;

		#get the $_ line number up to the current line the file is located on
		if($inc < $currentLineNumber-1) { #I did -1 because this fixed a bug where it cut off the
			$inc++;						#first file <CSP name...> tag because inc starts at 0
		}
		else {
			#this simply makes sure that the line number stored in the <BFH> file handler is current and won't let the files be printed unless it is
			$lineIsCurrent = 1;
		}
		
		if($lineIsCurrent == 1) {
			#get the $_ line number up to speed, I dont think I need this now because of the above code, I think I just need $inc = $currentLineNumber, but nonetheless I'm leaving it for safety
			while ($inc < $currentLineNumber) {
				$inc++;
			}
			
			if($printedOnce == 0) {
					#this is useful if you want to print something while debugging only once and not a bagillion times i.e. to print a statement to see what the $inc is during this iteration of the while loop (helpful to see if you are scanning through one individual CSP file that is within the whole massive export XML file)

					#print"inc $inc\n";
					#print"end $endOfFileLines[$i]\n";

					$printedOnce = 1;
			}

				################This is where you can do the checking, and also insert data into each CSP file individually. This will iterate through each and every line of the individual CSP file, until it is done with just that particular segment of that CSP file that is in the XML export

				#if you do not want to do any checking and replacing (i.e. only add something to the page, the just say print"$_"; and move on with your life... now is not the time to do this. That will be later in the code

				if($inc-1 <= $endOfFileLines[$i]) {
					#this will be where I do the replace feature to this Script
					if($_ =~ m/\<\![ ]*doctype html.*>/gi) {
						$matchedDoctypeAllOnTheSameLine = 1;
						print"matched ending on same line: line n. = $inc\n";						
					}
					elsif($_ =~ m/\<\![ ]*doctype html.*[^>].*/gi) {
						#this will account if the doctype is declared and doesn't finish on the same line with the > sign (NOT > is what [^>] means)
						$matchedDoctypeEndingOnDifferentLines = 1;
						print"matched ending on different line: line n. = $inc\n";
					}

				
					if($matchedHtmlAllOnTheSameLine) {
						#if it looks bad in the formatting, I fix it here
						#$temp = $_;
						#$temp =~ s/\<\![ ]*doctype.*\>/\n\<!doctype html\>\n/gi;

						#if($_ ne $temp) {
							#this line will print and add a comment if we changed the doctype formatting
						#	chomp ($temp);
						#	print"$temp <!-- sts/jce added 2016 02 05 -->\n";
						#}
						#else {
							#I didn't change it, so just print the line out to keep the file moving
						#	print"$_";
						#}
						 

						#print"inc $inc: end $endOfFileLines[$i]\n";
					}
					elsif($matchedDoctypeEndingOnDifferentLines) {
						#TODO
					}
					else {
						#we never encountered an doctype declaration with html so just print the line
						#print"$_";
					}

					####
					#if you want to skip any CSP files (i.e. not insert anything into them) you can do that here
					####
					#example: if($filesToUpdate[$i] eq "MARS.CSP" || $filesToUpdate[$i] eq "MARSLI.csp") {}
					if(2>1) {
						
						#do nothing
						
					}
					####
					#if you want to insert something into each CSP file you didn't exclude above, put your regex below in the if statement
					#if you want to replace something, however, it's going to take a little more work up above in the code
					####
					else {
						
												
					}


					#print "i = $inc; end = $endOfFileLines[$i]\n";
					$inc++;				
				}
				else { 

				################if you want to print something to go in between each CSP file, this is the place to do it. After the above if statement is done helping out the while loop while iterating through the file, after the while loop goes through the last line of the CSP file, the code ends up here. Hence, if you want to add something in between each file, go at it

					#print"inc = $inc and end of line = $endOfFileLines[$i]\n";
					#print"\n\n\n***\n\n\n";

					last;
				}
		}
	}

	#print"$currentLineNumber\n";

	
	$i++;
	$printedOnce = 0;
}
#print"\n$startOfFileLines[0]";



#these are the arrays that contain the file specific data:

#print"@filesToUpdate";
#print"@startOfFileLines\n";
#print"@endOfFileLines\n";

#print"$startOfFileLines[300] $filesToUpdate[300]\n";

#you can use scalar followed by the array to get the length of the array
#print scalar @filesToUpdate;

#make sure to close my file handles
close FH;
close AFH;
close BFH;