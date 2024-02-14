//
//  ContentView.swift
//  Animations
//
//  Created by Lucas Pennice on 10/02/2024.
//

import SwiftUI

struct ExpenseItem : Identifiable, Codable {
    var id = UUID()
    let name : String
    let type : String
    let amount : Double
}

@Observable
class Expenses {
    var items = [ExpenseItem](){
        didSet{
            guard let encodedItems = try? JSONEncoder().encode(items) else {return}
            
            UserDefaults.standard.set(encodedItems, forKey: "Items")
        }
    }
    
    init() {
        if let encodedSavedItems = UserDefaults.standard.data(forKey: "Items"){
            if let savedItems = try? JSONDecoder().decode([ExpenseItem].self, from: encodedSavedItems){
                items = savedItems
                return
            }
        }
    
        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    
    @State private var showingAddExpense = false
    
    var personalExpensesList : [ExpenseItem] {
        return expenses.items.filter{$0.type == "Personal"}
    }
    
    var businessExpensesList : [ExpenseItem] {
        return expenses.items.filter{$0.type == "Business"}
    }
    
    var body: some View{
        NavigationStack{
            List{
                Section{
                    Text("Business expense")
                        .font(.title3)
                    
                    ForEach(businessExpensesList){ item in
                        HStack{
                            VStack(alignment: .leading){
                                Text(item.name)
                                    .font(.headline)
                                
                                Text(item.type)
                            }
                            
                            Spacer()
                            
                            Text(item.amount, format: .currency(code: ("USD")))
                        }
                    
                    }
                    .onDelete(perform: removeItems)
                    .onMove { expenses.items.move(fromOffsets: $0, toOffset: $1) }
                }
                
                Section{
                    Text("Personal expense")
                        .font(.title3)
                    
                    ForEach(personalExpensesList){ item in
                                 HStack{
                            VStack(alignment: .leading){
                                Text(item.name)
                                    .font(.headline)
                                
                                Text(item.type)
                            }
                            
                            Spacer()
                            
                            Text(item.amount, format: .currency(code: ("USD")))
                        }
                        
                    }
                    .onDelete(perform: removeItems)
                    .onMove { expenses.items.move(fromOffsets: $0, toOffset: $1) }
                }
            }
            .navigationTitle("iExpenses")
            .toolbar{
                Button("Add", systemImage: "plus"){showingAddExpense = true}
                
                EditButton()
            }
            .sheet(isPresented: $showingAddExpense){
                AddView(expenses: expenses)
            }
        }
    }
    
    func removeItems(at offsets: IndexSet){
        expenses.items.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
