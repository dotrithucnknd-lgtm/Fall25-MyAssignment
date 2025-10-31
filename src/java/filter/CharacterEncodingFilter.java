package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import java.io.IOException;

/**
 * Filter to set UTF-8 encoding for all requests and responses.
 * This fixes Vietnamese input encoding issues.
 */
public class CharacterEncodingFilter implements Filter {
    
    private String encoding = "UTF-8";
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String encodingParam = filterConfig.getInitParameter("encoding");
        if (encodingParam != null && !encodingParam.isEmpty()) {
            this.encoding = encodingParam;
        }
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        // ALWAYS set encoding for requests FIRST
        request.setCharacterEncoding(encoding);
        
        // Check if this is a static resource (CSS, JS, images, etc.)
        String path = null;
        if (request instanceof jakarta.servlet.http.HttpServletRequest) {
            path = ((jakarta.servlet.http.HttpServletRequest) request).getRequestURI();
        }
        
        // Skip setting content-type for static resources only
        if (path == null || !path.matches(".*\\.(css|js|jpg|jpeg|png|gif|svg|ico|woff|woff2|ttf|eot)$")) {
            // For all HTML/JSP responses, ALWAYS set encoding and content-type
            response.setCharacterEncoding(encoding);
            
            // Set content-type with charset - this is critical for JSP rendering
            if (!response.isCommitted()) {
                response.setContentType("text/html; charset=" + encoding);
            }
        }
        
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        // Nothing to clean up
    }
}

