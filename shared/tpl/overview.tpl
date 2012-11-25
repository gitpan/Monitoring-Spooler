<html>
    <head>
        <title>Monitoring::Spooler - Overview</title>
    </head>
    <body>
        <h1>Groups</h1>
        [% FOREACH group IN groups %]
            [% IF loop.fist %]
            <ul>
            [% END %]
                <li>
                    <b>[% group.value.name %] ([% group.key %])[% IF group.value.paused_until %] - Alarme pausiert bis [% group.value.paused_until | localtime %][% END %]</b>
                    [% FOREACH msg IN group.value.msg_queue %]
                        [% IF loop.first %]
                        <h2>Message Queue</h2>
                        <ul>
                        [% END %]
                            <li>Message of type [% msg.type %] since [% msg.ts | localtime %]: [% msg.message %]</li>
                        [% IF loop.last %]
                        </ul>
                        [% END %]
                    [% END %]
                    <h2>Notification Queue</h2>
                    [% FOREACH user IN group.value.notify_queue %]
                        [% IF loop.first %]
                        <ol>
                        [% END %]
                           <li>[% user.name %] ([% user.number %])</li>
                        [% IF loop.last %] 
                        </ol>
                        [% END %]
                    [% END %]
                    
                    <form method="POST" action="">
                        <input type="hidden" name="rm" value="flush_messages" />
                        <input type="hidden" name="group_id" value="[% group.key %]" />
                        <button style="background-color:#fff">
                            <img src="/images/red_button_wikimedia.png" border="0" />
                            <br />
                            Flush Message Queue
                        </button>
                    </form>
                    
                    <h2>Notification Windows</h2>
                    [% FOREACH iv IN group.value.notify_intervals %]
                        [% IF loop.first %]
                        <ul>
                        [% END %]
                           <li>[% iv.type %] from [% iv.notify_from %] to [% iv.notify_to %]</li>
                        [% IF loop.last %] 
                        </ul>
                        [% END %]
                    [% END %]
                </li>
            [% IF loop.last %]
            </ul>
            [% END %]
        [% END %]
        
        <h1>Running Processes</h1>
        [% FOREACH proc IN running_procs %]
            [% IF loop.first %]
            <ul>
            [% END %]
               <li>[% proc.pid %] [% proc.type %] [% proc.name %]</li>
            [% IF loop.last %] 
            </ul>
            [% END %]
        [% END %]
    </body>
</html>