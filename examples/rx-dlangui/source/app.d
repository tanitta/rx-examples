module app;

import dlangui;
import rx;
import std.conv;

//main of this sample
import event;
import model;


mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {

	auto window = createAppWindow();

    auto counter = window.mainWidget.childById!EditLine("counter");

	auto appModel = new SampleModel;

	appModel.counter.doSubscribe((int n){
		counter.text = to!dstring(n);
	});
	counter.text = to!dstring(appModel.count);

	Disposable[] events;
	events ~= window.mainWidget.childById!Button("btnIncrement").click.asObservable().doSubscribe((Widget w) { appModel.increment(); });
	events ~= window.mainWidget.childById!Button("btnDecrement").click.asObservable().doSubscribe((Widget w) { appModel.decrement(); });

	window.mainWidget.childById!Button("btnDetach").click = (Widget w) {
		foreach (e; events) e.dispose();
		return true;
	};

    // close window on Close button click
    window.mainWidget.childById!Button("btnClose").click = delegate(Widget w) {
        window.close();
        return true;
    };

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}


Window createAppWindow()
{    // create window
    Log.d("Creating window");
    if (!Platform.instance) {
        Log.e("Platform.instance is null!!!");
    }
    Window window = Platform.instance.createWindow("DlangUI with Rx", null);
    Log.d("Window created");

    // create some widget to show in window
    //window.mainWidget = (new Button()).text("Hello, world!"d).margins(Rect(20,20,20,20));
    window.mainWidget = parseML(q{
        VerticalLayout {
            //margins: 10
            padding: 10
            layoutWidth: fill
            backgroundColor: "#C0E0E070" // semitransparent yellow background

            // red bold text with size = 150% of base style size and font face Arial
            TextWidget { text: "Rx example with DlangUI"; textColor: "red"; fontSize: 150%; fontWeight: 800; fontFace: "Arial" }

            // arrange some checkboxes horizontally
            HorizontalLayout {
                layoutWidth: fill
	            TextWidget { text: "Counter" }
	            EditLine { id: counter; text: "some text"; layoutWidth: fill }

				Button { id: btnIncrement; text: "+1" }
				Button { id: btnDecrement; text: "-1" }
            }

			Button { id: btnDetach; text: "Detach" }

			Button { id: btnClose; text: "Close" }
        }
    });


	return window;
}
