import SwiftUI

struct Login: View {
    
    @StateObject var loginData = LoginViewModel()
    @StateObject var createAccountData = CreateAccountViewModel()
    
    var body: some View {
        VStack{
            
            HStack{
                
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                
                Spacer(minLength: 0)
            }
            .padding()
                
            TextField("E-Mail", text: $loginData.email)
                .padding()
                .frame(width: UIScreen.main.bounds.width - 30)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .background(Color.white.opacity(0.06))
                .cornerRadius(15)
            
            SecureField("Password", text: $loginData.password)
                .padding()
                .frame(width: UIScreen.main.bounds.width - 30)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.default)
                .background(Color.white.opacity(0.06))
                .cornerRadius(15)
                
            .padding()
            .padding(.top,10)
            
            if(loginData.emailNotRegistered){
                Text("Error: Please check your e-mail and password.")
                    .padding()
                    .foregroundColor(.red)
            }
            
            
            if loginData.isLoading{
                ProgressView()
                    .padding()
            }
            else{
                Button(action: loginData.logIn, label: {
                    Text("Log-In")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 100)
                        .background(Color("blue"))
                        .clipShape(Capsule())
                })
                .disabled(loginData.email == "" || loginData.password == "" ? true : false)
                .opacity(loginData.email == "" || loginData.password == "" ? 0.5 : 1)
            }
            
            Spacer(minLength: 0)
            
            Text("New to Collabo?")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .padding()
            
            Button(action: createAccountData.createNewAccount, label: {
                Text("Create New Account")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 100)
                    .background(Color("blue"))
                    .clipShape(Capsule())
            })
            
            
        }
        .background(Color("bg").ignoresSafeArea(.all, edges: .all))
        
        .fullScreenCover(isPresented: $loginData.registerUser, content: {
            
            Register()
        })
        
        if(createAccountData.doCreateAccount){
            CreateAccount()
        }
        
    }
    
}

