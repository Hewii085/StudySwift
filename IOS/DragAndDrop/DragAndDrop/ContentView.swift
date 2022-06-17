//
//  ContentView.swift
//  DragAndDrop
//
//  Created by 윤성빈 on 2020/09/27.
//

import SwiftUI

struct DragableRect : View{
    let color : Color
    var name : String
    
    var body: some View {
        Rectangle()
            .fill(color).frame(width : 150, height: 150)
            .padding(2)
            .onDrag{ return NSItemProvider(object: name as NSString)  }
    }
}

struct ContentView: View {
    var body: some View {
        HStack{
            DroppableArea()
            
            VStack{
                DragableRect(color: Color.orange, name: "A")
                DragableRect(color: Color.red,name: "B")
            }
            
            VStack
            {
                DragableRect(color: Color.blue, name: "C")
                DragableRect(color: Color.yellow, name: "D")
            }
            
            
        }.padding(40)
    }
}

struct DroppableArea:View {
    @State private var active = 0
    
    var body : some View {
        let dropDelegate = MyDropDelegate(active: $active)
        
        return VStack{
            HStack{
                GridCell(active: self.active == 1)
                GridCell(active: self.active == 3)
            }
            
            HStack
            {
                GridCell(active: self.active == 2)
                GridCell(active: self.active == 4)
            }
        }.background(Rectangle().fill(Color.gray))
        .frame(width: 300, height: 300)
        .onDrop(of:["public.utf8-plain-text"], delegate: dropDelegate)
    }
}

struct GridCell: View
{
    let active : Bool
    
    var body: some View{
        return Rectangle()
            .fill(self.active ? Color.green : Color.clear)
            .frame(width: 150, height: 150)
    }
    
}

struct MyDropDelegate: DropDelegate
{
    @Binding var active: Int
       
    func validateDrop(info: DropInfo) -> Bool
    {
        return info.hasItemsConforming(to: ["public.utf8-plain-text"])
    }
       
    func dropEntered(info: DropInfo)
    {
           
    }
       
    func performDrop(info: DropInfo) -> Bool
    {
        let gridPosition = getGridPosition(location: info.location)
        //Case By Case
        self.active = gridPosition
           
        if let item = info.itemProviders(for: ["public.utf8-plain-text"]).first {
            item.loadItem(forTypeIdentifier: "public.utf8-plain-text", options: nil) { (urlData, error) in
                DispatchQueue.main.async {
                    if let urlData = urlData as? Data {
                        print("\(String(decoding : urlData, as: UTF8.self))")
                    }
                }
            }
               
            return true
               
        } else {
            return false
        }

    }
       
    func dropUpdated(info: DropInfo) -> DropProposal? {
        self.active = getGridPosition(location: info.location)
                    
        return nil
    }
       
    func dropExited(info: DropInfo) {
        self.active = 0
    }
       
    func getGridPosition(location: CGPoint) -> Int
    {
        print("position : \(location.x) , \(location.y)")
        if location.x > 150 && location.y > 150 {
            return 4
        } else if location.x > 150 && location.y < 150 {
            return 3
        } else if location.x < 150 && location.y > 150 {
            return 2
        } else if location.x < 150 && location.y < 150 {
            return 1
        } else {
            return 0
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View {
        ContentView()
    }
}
