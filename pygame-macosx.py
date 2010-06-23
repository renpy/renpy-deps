--- /tmp/pygame-1.8.1release/lib/macosx.py	2008-07-07 01:58:09.000000000 -0400
+++ macosx.py	2008-10-12 23:33:42.000000000 -0400
@@ -44,7 +44,7 @@
             win.retain()
         NSNotificationCenter.defaultCenter().removeObserver_name_object_(
             self, NSWindowDidUpdateNotification, None)
-        self.release()
+        # self.release()
 
 def setIcon(app):
     try:
@@ -61,7 +61,7 @@
 
 def install():
     app = NSApplication.sharedApplication()
-    setIcon(app)
+    # setIcon(app)
     appDelegate = PyGameAppDelegate.alloc().init()
     app.setDelegate_(appDelegate)
     appDelegate.retain()
