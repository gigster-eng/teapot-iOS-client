import UIKit

protocol PinterestLayoutDelegate {
  func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
}

class PinterestLayout: UICollectionViewFlowLayout {
  var delegate: PinterestLayoutDelegate!
  
  var numberOfColumns = 2
  var cellPadding: CGFloat = 5.0
  var itemInsets: UIEdgeInsets = UIEdgeInsetsZero
  
  private var cache = [UICollectionViewLayoutAttributes]()
  
  private var contentHeight: CGFloat = 0
  private var contentWidth: CGFloat {
    return CGRectGetWidth(collectionView!.bounds)
  }
  
  override func prepareLayout() {
    super.prepareLayout()
    
    let hasHeader = self.headerReferenceSize != CGSizeZero
    var headerAttributes: UICollectionViewLayoutAttributes? = nil
    
    if hasHeader && cache.isEmpty {
      //let contentOffset = self.collectionView!.contentOffset;
      let headerSize = self.headerReferenceSize;
      
      //create new layout attributes for header
      if let newHeaderAttributes = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forRow: 0, inSection: 0)) {
        let frame = CGRectMake(0, 0, collectionView!.bounds.width, headerSize.height); //offset y by the amount scrolled
        newHeaderAttributes.frame = frame;
        newHeaderAttributes.zIndex = 1024;
        headerAttributes = newHeaderAttributes
      }
    }
    
    if cache.isEmpty {
      let columnWidth = (contentWidth - (itemInsets.left + itemInsets.right)) / CGFloat(numberOfColumns)
      var xOffset = [CGFloat]()
      for column in 0 ..< numberOfColumns {
        xOffset.append(itemInsets.left + (CGFloat(column) * columnWidth))
      }
      var column = 0
      var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: hasHeader ? headerAttributes!.frame.size.height : 0)
      
      for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
        
        let indexPath = NSIndexPath(forItem: item, inSection: 0)
        
        let width = columnWidth - cellPadding * 2
        let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
        let height = cellPadding + annotationHeight + cellPadding
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.frame = insetFrame
        cache.append(attributes)
        
        contentHeight = max(contentHeight, CGRectGetMaxY(frame))
        yOffset[column] = yOffset[column] + height
        
        column = column >= (numberOfColumns - 1) ? 0 : ++column
      }
      
      if headerAttributes != nil {
        cache.append(headerAttributes!)
      }
    }
  }
  
  func emptyLayoutCache() {
    cache = [UICollectionViewLayoutAttributes]()
    contentHeight = 0
  }
  
  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    for attributes in cache {
      if CGRectIntersectsRect(attributes.frame, rect) {
        layoutAttributes.append(attributes)
      }
    }
    return layoutAttributes
  }
  
  override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
    attributes.frame = CGRect(x: 0, y: 0, width: contentWidth, height: self.headerReferenceSize.height)
    
    return attributes
  }
}
