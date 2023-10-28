import cv2

colors = [
    [(165, 50, 25), (5, 255, 255)], # Red
    [(6, 75, 25), (25, 255, 255)], # Orange 
    [(26, 50, 25), (35, 255, 255)], # Yellow not captured
    [(50, 30, 25), (90, 255, 255)], # Green not captured
    [(100, 60, 25), (130, 255, 255)], # Blue white captured
    [(0, 0, 200), (180, 255, 255)], # White
] 

image = cv2.cvtColor(cv2.imread('file2.jpg'), cv2.COLOR_BGR2HSV)

for color in colors:
    if color[0][0] > color[1][0]:
        mask1 = cv2.inRange(image, color[0], (180, 255, 255))
        mask2 = cv2.inRange(image, (0, 75, 25), color[1])
        mask = cv2.bitwise_or(mask1, mask2)
    else:
        mask = cv2.inRange(image, color[0], color[1])
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, None, iterations=2)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, None, iterations=2)
    cv2.imshow('mask', mask)
    cv2.waitKey(0)
    cv2.destroyAllWindows() 