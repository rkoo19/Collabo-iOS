import SwiftUI

struct ContentView: View {
    @AppStorage("current_status") var status = false
    var body: some View {

        NavigationView{
            
            VStack{
                //Login()
                
                if status{Home()}
                else{Login()}
            }
            .preferredColorScheme(.dark)
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
