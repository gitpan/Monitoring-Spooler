[% INCLUDE includes/header.tpl %] 

<div class="container">
   <div class="rows">
      <div class="span4">
         <h2>Message Queue</h2>
         <table class="table table-striped">
         <thead>
            <tr>
               <td>Type</td>
               <td>since</td>
               <td>Message</td>
            </tr>
         </thead>
         <tbody>
         [% FOREACH msg IN msg_queue %]
            <tr>
               <td>[% msg.type %]</td>
               <td>[% msg.ts | localtime %]</td>
               <td>[% msg.message %]</td>
         [% END %]
         </tbody>
         </table>
         <a class="btn btn-danger btn-large" href="?rm=flush_messages&group_id=[% group_id %]">Flush Message Queue(s)</a>
      </div>
      <div class="span4">
         <h2>Notification Queue</h2>
         <table class="table table-striped">
         <thead>
            <tr>
               <td>Name</td>
               <td>Number</td>
            </tr>
         </thead>
         <tbody>
         [% FOREACH p IN notify_order %]
            <tr>
               <td>[% p.name %]</td>
               <td>[% p.number %]</td>
         [% END %]
         </tbody>
         </table>
      </div>
      <div class="span4">
         <h2>Notification Windows</h2>
         <table class="table table-striped">
         <thead>
            <tr>
               <td>Type</td>
               <td>From</td>
               <td>To</td>
            </tr>
         </thead>
         <tbody>
         [% FOREACH iv IN notify_intervals %]
            <tr>
               <td>[% iv.type %]</td>
               <td>[% iv.from %]</td>
               <td>[% iv.to %]</td>
         [% END %]
         </tbody>
         </table>
      </div>
   </div><!-- /rows -->
</div>
[% INCLUDE includes/footer.tpl %]

