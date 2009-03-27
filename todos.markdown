### 0.1

* DONE bug: In messages ending in punctuation (e.g No tags.) the punctuation is removed when replaced (e.g <%= I18n.t("users.show.no_tags") %>)

### 0.1.1

* DONE bug: indenting whitespace is removed around replaced messages
This is easy to fix, the whitespace has to be readded just like the punctuation

    <% tags = @photo.tag_list %>
      Tags:
    <% if !tags.blank? %>

    becomes

    <% tags = @photo.tag_list %><%= I18n.t("mysite.tags") %><% if !tags.blank? %>

### 0.2

* list the files that are about to be changed an ask for confirmation to go ahead
* think about which rails helpers could be given text that needs to be internationalized (currently only link_to is scanned)
* DONE make it possible to run i15r on several files

### 0.?

* make interactive mode possible. the user is asked about each message to be replaced. he can choose to replace it, skip it or even edit it. Ideally the message would be shown in its context.
* handle non-ascii characters properly (UTF-8 support) when replacing them. Mañana should become I18n.t("prefix.manana"), for instance.
