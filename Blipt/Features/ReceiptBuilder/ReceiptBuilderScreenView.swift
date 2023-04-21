import SwiftUI

struct ReceiptBuilderScreenView<Destination>: View where Destination : View {
  typealias ReceiptBuilderContentDestination = ([Item]) -> Destination
  
  let destination: ReceiptBuilderContentDestination
  @State var items: [Item]
  @State private var currentCost: Price = .zero
  @State private var plateOffset: CGSize = .zero
  
  init(items: [Item], @ViewBuilder destination: @escaping ReceiptBuilderContentDestination) {
    self.items = items
    self.destination = destination
  }
  
  @ViewBuilder
  var tableButton: some View {
    NavigationLink {
      ReceiptView(title: "Current Items", items: items) { item in
        items.removeAll { $0.id == item.id }
      }
    } label: {
      ItemTableView(itemCount: items.count)
    }
  }
  
  @ViewBuilder
  var nextScreenButton: some View {
    NavigationLink {
      destination(items)
    } label: {
      Text("Done")
        .frame(maxWidth: .infinity)
    }.buttonStyle(AppButtonStyle())
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        tableButton
        Spacer()
        PlateView(cost: currentCost)
          .offset(plateOffset)
          .gesture(
            DragGesture()
              .onChanged { value in
                plateOffset = value.translation
              }
              .onEnded { value in
                if isOnTable(value.translation) && currentCost.amount > 0 {
                  items.append(Item(name: "Item \(items.count)", cost: currentCost.amount))
                }
                plateOffset = .zero
              }
          )
        NumberPadView { button in
          handleButtonPress(button)
        }
        nextScreenButton
      }
      .padding()
    }
  }
  
  func isOnTable(_ translation: CGSize) -> Bool {
    return translation.height < -50 && abs(translation.width) < 100
  }
  
  func handleButtonPress(_ button: String) {
    switch button {
    case "⌫":
      currentCost.amount = (currentCost.amount / 10).rounded(toPlaces: 2)
    default:
      if let number = Double(button), currentCost.amount < 9999.99 {
        currentCost.amount = currentCost.amount * 10 + number * 0.01
      }
    }
  }
}

struct ReceiptBuilderView_Previews: PreviewProvider {
  static var previews: some View {
    ReceiptBuilderScreenView(
      items: .stub(),
      destination: { items in Text("Next Screen Sample with: \(items.count)") }
    )
  }
}
