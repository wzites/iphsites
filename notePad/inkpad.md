---
layout: notepad
---

{% for note in site.data.inkpad %}
<hr>
### {{ note.title }} [🖨](https://inkpadnotepad.appspot.com/notes/print?key={{note.key}})
  > {{ note.content }}
{% endfor %}

* [json](https://inkpadnotepad.appspot.com/api/export?output=json&offset=-120)
