#!/bin/zsh -f

# Change this to the path of whatever app you want to use
APP='/Applications/ABBYY FineReader Express.app'

MOVE_TO="$HOME/Action/Done"

if (( $+commands[growlnotify] ))
then
		# if the growlnotify command is found, we'll use it AND 'logger'

	logit () {

	logger -si "$@"

	growlnotify  \
		--appIcon "$APP:t"  \
		--identifier "HazelOCR"  \
		--message "$@"  \
		--title "Hazel OCR with $APP:t"

	}

else

		# if growlnotify is not found we'll just use 'logger'

	logit () {

	logger -si "$@"

	}

fi

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####


if [[ -d "$APP" ]]
then

	# if the app exists


	# Check to see if the file exists & is readable
	FILE="$@"


	if [[ -r "$FILE" ]]
	then

			# if the file is readable, tell the user we are going to OCR it
		logit "Opening $FILE in $APP:t"

		SUCCESS=no

			# open a new copy of the app and send the file to it
		open -W -n -a "$APP:t" "${FILE}" && SUCCESS=yes

		if [ "$SUCCESS" = "yes" ]
		then
				logit "Successfully OCR'd $FILE:t"

				# if that app exits successfully,
				# move the  file to MOVE_TO folder
				# which we create using 'mkdir' just in case it doesn't exist
				# and then exit 0
				# if any of these steps fail, the whole script should exit 1

			mkdir -p "$MOVE_TO" || exit 1

			TARGET="$MOVE_TO/$FILE:t"

			if [[ -e "$TARGET" ]]
			then
					# what do we do if the target file already exists in $MOVE_TO ?
					# Let's try to come up with a new filename based on the current time

				zmodload zsh/datetime

				TIME=$(strftime %Y-%m-%d--%H.%M.%S "$EPOCHSECONDS")

					# This is the filename without leading path or extension
				SHORT="$FILE:r:t"

					# We try to rename the file based on current time.
					# if THAT doesn't work we still exit ugly
				mv -vn "$FILE" "$MOVE_TO/$SHORT.$TIME.pdf" || exit 1


			else
					# move file to directory, exit 1 if it fails
				mv -vn "$FILE" "$MOVE_TO" || exit 1

			fi

				# tell the user we renamed the file
			logit "Moved $FILE to $MOVE_TO"

				# exit 0 if we arrived here (against all odds :-)
			exit 0
		fi

	else
			# if the file doesn't exist
		logit "File does not exist or is not readable: $FILE"
	fi

else
		# if the app is not found
	logit "[Hazel] Did not find APP at $APP"

fi

	# if we get here, something went wrong, so we exit = 1
	# which will get Hazel to report that something went wrong
exit 1

#EOF