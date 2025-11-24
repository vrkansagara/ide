<?php

// Create top level window object and give it a title
$window = new GtkWindow();
$window->set_title('Hello world');

// Connect the 'destroy' action to GTK's main_quit function
// so the program exits when the window is closed
$window->connect_simple('destroy', array('gtk', 'main_quit'));

// Add an element to the window
$label = new GtkLabel("Hello\n\nWorld!");
$window->add($label);

// Tell all windows to set visible
$window->show_all();

// Run!
Gtk::main();

