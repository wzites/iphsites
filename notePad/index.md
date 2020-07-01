---
layout: notepad
---
## Michel's inkPad notes

* my [inkpad](https://inkpadnotepad.appspot.com/notes) [notes](inkpad.html)
{% for note in site.data.inkpad %} * [{{ note.title }}](https://inkpadnotepad.appspot.com/notes/print?key={{note.key}})
{% endfor %}

