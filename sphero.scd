s.boot;
s.scope;

/* ideas:
	- axion buzzing and fitzing
	- collision bang
	- voice clips 
*/

SynthDef(\twin, {
	|x=0,y=0,xvel=0,yvel=0,out=1,amp=0.01|
	var sig, base = (x+y+xvel+yvel).sqrt + 200;
	base = DelayL.ar(base, 1.0, 0.75, 0.5, base);
	sig = Mix.ar(SinOsc.ar(base, x, amp),
		SinOsc.ar(base*2, y, amp),
		SinOsc.ar(base*3, xvel, amp),
		SinOsc.ar(base*4, yvel, amp),
		SinOsc.ar(base*5, 0, amp/x),
		SinOsc.ar(base*6, 0, amp/y),
		SinOsc.ar(base*7, 0, amp/xvel),
		SinOsc.ar(base*8, 0, amp/yvel));
	Out.ar(out,
		DelayL.ar(sig, 0.9, 0.5, 0.5, sig))
}).add();
~twin = Synth(\twin);
~twin.free;
b = Buffer.read(s,"goldberg-aria-da-capo.wav")

SynthDef(\bbb, {
	|x=0,y=0,xvel=0,yvel=0,out=0,accel=100,amp=0.01|
	Out.ar(out,
		Mix.ar(
			BufRd.ar(1, b, LFSaw.ar((x/1000.0)*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
			BufRd.ar(1, b, LFSaw.ar((y/1000.0)*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
			BufRd.ar(1, b, LFSaw.ar(((yvel*xvel)/(50*50.0))*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
		))

	//BufRd.ar(1, b, ((x+y+yvel)/1000.0).wrap(0,1.0)+LFSaw.ar((1.0/7.0)*BufDur.ir(b).reciprocal,iphase: x/1000.0).range(0, BufFrames.ir(b))))

		//BufRd.ar(1, b, x*y*LFSaw.ar(BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b)) ))
	    //BufRd.ar(1, b, x/1000 * BufFrames.ir(b)))
}).add();
~bbb = Synth(\bbb);
//~bbb.free;



~listener = {|msg, time, addr, recvPort| 
	~twin.set(\x, msg[1]);
	~twin.set(\y, msg[2]);
	~twin.set(\xvel, msg[4]);
	~twin.set(\yvel, msg[5]);

	~bbb.set(\x, msg[1]);
	~bbb.set(\y, msg[2]);
	~bbb.set(\accel, msg[3]);
	~bbb.set(\xvel, msg[4]);
	~bbb.set(\yvel, msg[5]);


	msg.postln
};


~collision = OSCFunc.newMatching(~listener, '/collision');
~locator = OSCFunc.newMatching(~listener, '/locator');

/*

OSCFunc.defaultDispatcher.unregister('/locator')
OSCFunc.defaultDispatcher.unregister('/collision')
OSCdef(\test).enable;
OSCdef(\collision, ~listener, '/collision', n);
OSCdef(\locator, ~listener, '/locator', n);

~collision
n = NetAddr("127.0.0.1", NetAddr.langPort); // loopback
OSCdef(\locator,
	{|msg, time, addr, recvPort| \matching.postln}, '/locator', n);
OSCdef(\locator,
	{|msg, time, addr, recvPort| msg.postln}, '/locator');
OSCdef(\collision,
	{|msg, time, addr, recvPort| "collision2".postln; msg.postln}, '/collision',n);


m = NetAddr("127.0.0.1", NetAddr.langPort); // loopback
m.sendMsg("/locator", "Hello App 1");
m.sendMsg("/collision", "Hello App 1");

*/