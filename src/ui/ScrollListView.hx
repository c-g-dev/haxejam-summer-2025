package ui;

import ludi.heaps.box.Box;
import ludi.heaps.box.Containers.ScrollBox;

class ScrollListItem {
    var box: Box;
}

class ScrollListView extends h2d.Object {
    var background: Box;
    var scrollbox: ScrollBox;
    var scrollbar: h2d.Object;
}