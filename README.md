Draws Animated Curved and Straight Lines between two points.

## Usage

**Creating a Curved Line**
```dart  
var curvedLine = LineInfo(  
  source: Offset.zero,  
  destination: const Offset(100, 100),  
  backgroundLineColor: Colors.black,  
  progressLineColor: Colors.lightGreen,  
  lineStyle: LineStyle.curved(),  
  strokeStyle: StrokeStyle.dashed(),  
  animationCount: 4,  
);  
```  

**Creating a Straight Line**
```dart  
var straightLine = LineInfo(  
  source: Offset.zero,  
  destination: const Offset(100, 100),  
  backgroundLineColor: Colors.black,  
  progressLineColor: Colors.lightGreen,  
  lineStyle: LineStyle.straight(),  
  strokeStyle: StrokeStyle.dashed(),  
  animationCount: 4,  
); 
``` 

**Dashed stroke  can be achieved by configuring the strokeStyle as**
```dart  
var strokeStyle = StrokeStyle.dashed(gapLength: 5,dashLength: 5);
``` 
`gapLength` and `dashLength` are both optional

**Plain stroke can be achieved by configuring the strokeStyle as**
```dart  
var strokeStyle = StrokeStyle.plain();
``` 

**Straight Line can be achieved by configuring the lineStyle as**
```dart  
var lineStyle = LineStyle.straight();
``` 

**Curved Line can be achieved by configuring the lineStyle as**
```dart  
var strokeStyle = LineStyle.curved(radius: 100,isClockwise: true);
``` 
`radius` and `isClockwise` are both optional


**Animating progress**
```dart  
line.animate();
```  
providing `animationCount < 0` while creating line object denotes animation to continue indefinitely.

**Stopping animation**
```dart  
line.stopAnimation();
```  

**Listening to animation end**
```dart  
line.onAnimationComplete = () {  
  //TODO: Execute Code On animation end  
};
```