function reggui_send_mail(dest_mail,header,message,attachment)

[~,reggui_config_dir] = get_reggui_path;
reggui_mail_config = fullfile(reggui_config_dir,'reggui_mail_config.txt');

if(not(exist(reggui_mail_config,'file')))
   disp('Cannot find mail configuration file (',reggui_mail_config,')')
   return
end

myaddress = '';
mypassword = '';
smtp_server = '';
smtp_class = 'javax.net.ssl.SSLSocketFactory';
smtp_port = '465';

try
    fid = fopen(reggui_mail_config,'r');
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        if(not(isempty(strfind(tline,'address:'))))
            myaddress = fgetl(fid);
        elseif(not(isempty(strfind(tline,'password:'))))
            mypassword = fgetl(fid);
        elseif(not(isempty(strfind(tline,'smtp_server:'))))
            smtp_server = fgetl(fid);
        elseif(not(isempty(strfind(tline,'smtp_class:'))))
            smtp_server = fgetl(fid);
        elseif(not(isempty(strfind(tline,'smtp_port:'))))
            smtp_server = fgetl(fid);
        end
    end
    fclose(fid);
catch
    disp('Could not load the e-mail configuration parameters.')
    fclose(fid);
end

setpref('Internet','E_mail',myaddress);
setpref('Internet','SMTP_Server',smtp_server);
setpref('Internet','SMTP_Username',myaddress);
setpref('Internet','SMTP_Password',mypassword);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class',smtp_class);
props.setProperty('mail.smtp.socketFactory.port',smtp_port);

sendmail(dest_mail,header,message,attachment);
