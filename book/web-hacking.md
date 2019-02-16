# web hacking

## types of vulnerabilities

* Open Redirect
    * allows you to abuse domain abuse by putting malicious URL for redirect (https://facebook.com?source=http://attacker.com/)
    * tools
* HTTP Parameter Pollution
    * checking for application behaviour when multiple same name parameters are specified like http://mybounty.com/profile?id=1?id=2
    * tools
* Cross-Site Request Forgery (CSRF)
    * allows to make requests on other sites (in background) knowing that user is logged in and can make requests (like POST /delete_profile)
* HTML Injection
    * allows for plain HTML injection (think of <iframe> or <script>) on page if input is somehow decoded
* CRLF Injection
    * injection of carriage return line feed
    * complex technique, allows for various injection, WAF bypass when application is not properly decoding these signs
* Cross-Site Scripting
    * simply putting <script> on site, which results on execution of JavaScript (send cookies of user to external site!)
* Template Injection
    * SSTI - Server Side
    * CSTI - Client Side
        * hard to achieve, due to sandboxes in Angular, possible XSS
        * https://developer.uber.com/docs/deep-linking?q=wrtz{{7*7}}
* SQL Injection
    * SQL queries which allow to bypass auth mechanism and extract data from database
* Server Side Request Forgery
    * allows for making requests on behalf of vulnerable server to discover internal resources for example
* XML External Entity Vulnerability
    * allows for inclusion of external entities (like files) inside XML file
* Remote Code Execution
    * code execution on behalf of vulnerable component like web-server
* Memory
    * various deep, low-level attacks like buffer overflow...
* Sub Domain Takeover
    * claim of non-existing domain, to which, some CNAME records points (and then abuse of trust using that CNAME)
* Race Conditions
    * multiple requests in short span of time in hope of getting some operation being duplicated (transfer credits etc.)
* Insecure Direct Object References
    * access objects directly without needed privileges (http://facebook.com/user_profile_admin.php?id=<other_id_here>)
* OAuth
    * tinkering with code/token responses from OAuth and resource server on the way
* Application Logic Vulnerabilities
    * closed doors won't help if windows are open...
