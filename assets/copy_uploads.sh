scp -r deploy@pat.powertochange.org:/var/www/pat.powertochange.org/shared/public/event_groups /var/www/pat.powertochange.org/shared/public/event_groups
scp -r deploy@pat.powertochange.org:/var/www/dev.pat.powertochange.org/shared/public/event_groups /var/www/pat.dev.powertochange.org/shared/public/event_groups

# could be modified to compress first, would speed things
scp -r deploy@pat.powertochange.org:/var/www/mpdtool.powertochange.org/shared/public/mpd_letter_images /var/www/mpdtool.powertochange.org/shared/public/mpd_letter_images
scp -r deploy@pat.powertochange.org:/var/www/dev.mpdtool.powertochange.org/shared/public/mpd_letter_images /var/www/mpdtool.dev.powertochange.org/shared/public/mpd_letter_images

scp -r deploy@pat.powertochange.org:/var/www/pulse.campusforchrist.org/shared/public/emu.profile_pictures
scp -r deploy@pat.powertochange.org:/var/www/moose.campusforchrist.org/shared/public/emu_dev.profile_pictures
scp -r deploy@pat.powertochange.org:/var/www/emu.campusforchrist.org/shared/public/emu_stage.profile_pictures
