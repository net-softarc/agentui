package agentui.proxy

import uk.me.lings.scalaguice.ScalaModule
import com.google.inject.Provider
import net.model3.guice.M3GuiceModule
import com.google.inject.util.Modules
import com.google.inject.Module
import m3.servlet.M3ServletModule



class GuiceModule extends ScalaModule with Provider[Module] {

  def get = Modules.`override` (
      new M3GuiceModule()
  ).`with`(
      this,
      ServletModule
  )

  def configure = {    
  }

  object ServletModule extends M3ServletModule {
    override def configureServlets = {
      
//      serve("/post").`with`(classOf[ProxyServlet])
//      serve("/sessionPing").`with`(classOf[ProxyServlet])
      serve("/api").`with`(classOf[ProxyServlet])
      
    } 
  }
  
}