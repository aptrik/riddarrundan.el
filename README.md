# riddarrundan.el

Minor mode for emacs to help speed up registration of
[Riddarrundan results](http://www.slottskorgen.se/riddarrundan/).

    (add-to-list 'load-path ".../riddarrundan.el")
    (require 'riddarrundan)

Open a yml-file and turn on ``M-x riddarrundan-mode``.

Or turn on riddarrundan-mode in all yaml-mode buffers.

    (add-hook 'yaml-mode-hook 'riddarrundan-mode)
