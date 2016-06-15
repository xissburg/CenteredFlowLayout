# Centered Flow Layout for iOS

The [CenteredFlowLayout](https://github.com/xissburg/CenteredFlowLayout/blob/master/CenteredFlowLayout/CenteredFlowLayout.swift) class is a collection view layout which centers the elements in the collection view. To use it in Interface Builder all you have to do is to set your collection view layout to custom and choose `CenteredFlowLayout` as the class, right click _Centered Flow Layout_ in the Document Outline pane on the left and assign your view controller as its delegate<sup>[1](#myfootnote1)</sup>, and lastly implement the `CenteredFlowLayoutDelegate` in your view controller which consists of a single method that returns the cell size at a given index path.

<a name="myfootnote1">1</a>: There's a known bug in Interface Builder where you cant assign the delegate to anything in this case. Then change the `delegate` of `CenteredFlowLayout` to `AnyObject?` and it should work.
